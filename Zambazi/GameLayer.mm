//
//  GameLayer.m
//
//  Created by Arthur Street on 15/10/12.
//
//
//  Images from  http://www.vickiwenderlich.com/
//

#import "GameLayer.h"
#import "GameModel.h"

@interface GameLayer() {}
@property (nonatomic, readonly) CGSize winSize;
    
@property (nonatomic, strong) GameModel* gameModel;

@property (nonatomic, strong) NSArray* elementNames;
@property (nonatomic, strong) NSArray* actionNames;
    
@property (nonatomic, strong) CCSpriteBatchNode *spriteSheet;
//
// keys are animal types, e.g. "bear"
//
@property (nonatomic, strong) NSMutableDictionary* walkNames;    // keys NSString, values NSString, e.g. {bear: bear_walk, parrot: parrot_fly}.
@property (nonatomic, strong) NSMutableDictionary* initialFrame; // keys NSString, value CCSprintFrame - gives first frame to show
//
// keys are animal type _ action type, e.g. "bear_walk", "parrot_fly"
//
@property (nonatomic, strong) NSMutableDictionary* genericActions; // keys NSString, values CCAction
//
// keys are animal type _ animal number, e.g. "bear_1", "parrot_2"
//
@property (nonatomic, strong) NSMutableDictionary* currentActions;  // keys NSString, values @{@"name":NSString, @"action":CCActions}
//
// keys are GameElements
//
@property (nonatomic, strong) NSMutableDictionary* sprites;      // keys GameElements, values CCSprite

@end

@implementation GameLayer

// on "init" you need to initialize your instance
-(id) init {
    if((self = [super init])) {
        #define MAX_FRAMES_PER_ACTION 8
        self->_gameModel      = nil;  // this is set when the model sends a notification that it has been created
        self->_elementNames   = @[@"grassfront", @"grassbehind", @"bear", @"monkey"];
        self->_actionNames    = @[@"idle", @"walk", @"fly"];
        
        self->_walkNames      = [NSMutableDictionary dictionaryWithCapacity:[self->_elementNames count]];
        self->_initialFrame   = [NSMutableDictionary dictionaryWithCapacity:[self->_elementNames count]];
        self->_genericActions = [NSMutableDictionary dictionary];
        self->_sprites        = [NSMutableDictionary dictionary];
        self->_currentActions = [NSMutableDictionary dictionary];
        
        self->_winSize = [CCDirector sharedDirector].winSize;
        CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        
        //
        // Main background
        //
        
        [frameCache addSpriteFramesWithFile:@"bg-iPad.plist"];
        
        CCSprite * background = [CCSprite spriteWithSpriteFrameName:@"bg-iPad.png"]; // named in background.plist
		
        //ccTexParams params = {GL_LINEAR,GL_LINEAR,GL_REPEAT,GL_REPEAT}; // would have to be power of 2 to repeat
		background.position = ccp(self->_winSize.width /2, self->_winSize.height /2);
		//[background.texture setTexParameters:&params];
        [self addChild:background];
        //background.anchorPoint = ccp(0,0);
        //background.position = ccp(0,0);
        //background.scale = 0.8;
        
        [frameCache addSpriteFramesWithFile:@"monkeypics_default.plist"];
        self->_spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"monkeypics_default.png"];
        [self addChild:self->_spriteSheet];
        
        //
        // Set up arrays of the game element sprites
        //
        for (NSString* elementName in self->_elementNames)
            for (NSString* actionName in self->_actionNames) {
                NSMutableArray *frames = [NSMutableArray array];
                for(int i = 1; i <= MAX_FRAMES_PER_ACTION; i++) {
                    CCSpriteFrame* possibleFrame = [frameCache spriteFrameByName: 
                                       [NSString stringWithFormat:@"%@_%@_%d.png", elementName, actionName, i]];
                    if (possibleFrame) {
                        [frames addObject: possibleFrame];
                        // the first action we find in the list will do for the initial frame of this animal
                        if (![self->_initialFrame objectForKey:elementName]) {
                            [self->_initialFrame setObject:possibleFrame forKey:elementName];
                        }
                        // the first non-idle action we find in the list is our "walk" animation
                        if ((actionName!=@"idle") && (![self->_walkNames objectForKey:elementName])) {
                            [self->_walkNames setObject:[GameLayer keyFromElementName:elementName andActionName:actionName] forKey:elementName];
                        }
                    }
                }
                if ([frames count]>1) {
                    // it's not really an animation if there's only one frame
                    CCAnimation* animation = [CCAnimation animationWithSpriteFrames:frames delay:0.1f];
                    CCAction* action = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animation]];
                    [self->_genericActions setObject: action forKey:[GameLayer keyFromElementName:elementName andActionName:actionName]];
                }
            }
        
        //
        //  Register for model events that are important to this layer
        //
        
        NSNotificationCenter* noticenter = [NSNotificationCenter defaultCenter];
        [noticenter addObserver:self selector:@selector(reviseElementsNotification:) name:@"reviseElements" object:nil];
        [noticenter addObserver:self selector:@selector(registerModelNotification:) name:@"registerModel" object:nil];
        
        self.isTouchEnabled = YES;
    }
    return self;
}


+(NSString*) keyFromElementName:(NSString*)eltName andActionName:(NSString*) actionName {
    return [NSString stringWithFormat:@"%@_%@", eltName, actionName];
}

-(CGPoint) layerPosFromModelPos:(Point3D)where {
    float x = self.winSize.width * (where.x/self.gameModel.worldWidth);
    float y = self.winSize.height * (where.y/self.gameModel.worldHeight);
    return ccp(x, y);
}


-(void) reviseElements {
    //
    // Add any new elements and set them idling
    //
    NSArray* spritedElements = [self.sprites allKeys];
    for (GameElement* element in self.gameModel.elements) {
        if (![spritedElements containsObject:element]) {
            NSLog(@"Adding %@ %p", element.appearName, element);
            CCSprite* sprite = [CCSprite spriteWithSpriteFrame:[self.initialFrame objectForKey:element.appearName]];
            sprite.position = [self layerPosFromModelPos:element.where];
            sprite.scale = element.scale;
            [self.spriteSheet addChild:sprite];
            [self.sprites setObject:sprite forKey:element];
            NSString* idleKey = [GameLayer keyFromElementName:element.appearName andActionName:@"idle"];
            CCAction* idleAction = [[self.genericActions objectForKey:idleKey] copy];
            if (idleAction) {
                [sprite runAction:idleAction];
                // keep track of this action so we can stop it later
                [self.currentActions setObject:@{@"action":idleAction, @"name":idleKey} forKey:element];
            }
        }
    }
    //
    // Delete any elements that are not there
    //
    for (GameElement* element in spritedElements) {
        if (![self.gameModel containsElement:element]) {
            NSLog(@"Removing %@ %p", element.appearName, element);
            CCSprite* sprite = [self.sprites objectForKey:element];
            [sprite removeFromParentAndCleanup:YES]; // find out what YES means here
            [self.sprites removeObjectForKey:element];
            [self.currentActions removeObjectForKey:element];
        }
    }
}


#pragma mark - Notifications from the model

-(void) registerModelNotification:(NSNotification*) notification {
    GameModel* model = (GameModel*) [notification object];
    NSLog(@"Registering model with GameLayer");
    self.gameModel = model;
}

-(void) reviseElementsNotification:(NSNotification*) notification {
    //GameModel* model = (GameModel*) [notification object];
    //NSLog(@"Revising elements on GameLayer");
    [self reviseElements]; // temp
}



-(void) registerWithTouchDispatcher
{
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
	return YES;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [touch locationInView: [touch view]];		
    touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
    touchLocation = [self convertToNodeSpace:touchLocation];
    
    for (GameElement* element in self.sprites) { // sprites is a dictionary, and enumerates its keys
        if ([element isKindOfClass:[Animal class]]) {
            Animal* animal = (Animal*) element;
            if (rand0to1<0.2) {
                animal.moving = NO;
            } else {
                [animal applyImpulseToVelocity:Point3DMake((rand0to1-0.5)*10., (rand0to1-1.)*10., 0.)];
                animal.moving = YES;//((fabs(animal.velocity.x)>0.001) && (fabs(animal.velocity.y)>0.001));
            }
            NSDictionary* previousActionAndName = [self.currentActions objectForKey:element];
            NSString* previousActionName = [previousActionAndName objectForKey:@"name"];
            CCAction* previousAction = [previousActionAndName objectForKey:@"action"];
            CCSprite* sprite = [self.sprites objectForKey:element];
            NSString* walkKey = [self.walkNames objectForKey:animal.appearName];
            NSString* idleKey = [GameLayer keyFromElementName:animal.appearName andActionName:@"idle"];
            //NSLog(@"previous action %@ animptr %p", previousActionName, previousAction);
            if (animal.moving && ((!previousAction) || (previousActionName!=walkKey))) {
                // Animal was not walking before, so start it walking
                // Cocos requires that we use a copy of the master walk action
                CCAction* walkAction = [[self.genericActions objectForKey:walkKey] copy];
                if (previousAction) {
                    [sprite stopAction:previousAction];
                    [self.currentActions removeObjectForKey:animal];
                }
                if (walkAction) {
                    [sprite runAction:walkAction];
                    // keep track of this action so we can stop it later
                    [self.currentActions setObject:@{@"action":walkAction, @"name":walkKey} forKey:animal];
                }
                //NSLog(@"new action %@ animptr %p", walkKey, walkAction);
            } else if ((!animal.moving) && ((!previousAction) || (previousActionName!=idleKey))) {
                // Animal was walking before, and we need to go to the idle action
                CCAction* idleAction = [[self.genericActions objectForKey:idleKey] copy];
                if (previousAction) {
                    [sprite stopAction:previousAction];
                    [self.currentActions removeObjectForKey:animal];
                }
                if (idleAction) {
                    [sprite runAction:idleAction];
                    // keep track of this action so we can stop it later
                    [self.currentActions setObject:@{@"action":idleAction, @"name":idleKey} forKey:animal];
                }
                //NSLog(@"new action %@ animptr %p", idleKey, idleAction);
            }
            // may need to flip it too
            // assumes they all face right - in fact bear is in backwards
            if (animal.moving)
                sprite.flipX = [animal.appearName isEqualToString:@"bear"] ? (animal.velocity.x>0) : (animal.velocity.x<0);

        }
    }
    
}


#pragma mark - Updatable protocol

-(void) update:(ccTime)dt {
    // to do
    NSArray* elements = [self.sprites allKeys];
    for (GameElement* element in elements) {
        CCSprite* sprite = [self.sprites objectForKey:element];
        sprite.position = [self layerPosFromModelPos:element.where];
        sprite.rotation = element.rotation;
    }
}


@end
