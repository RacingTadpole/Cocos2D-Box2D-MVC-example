//
//  GameModel.m
//
//  Created by Arthur Street on 17/10/12.
//

#import "GameModel.h"

@interface GameModel () {}
@property (nonatomic) b2World *world;

@end

@implementation GameModel

const float kWorldWidth = 20.0;  // metres
const float kWorldHeight = 10.0;

#pragma mark - Initialization

static GameModel *sharedInstance = nil;

+ (GameModel*) sharedModel {
    if (!sharedInstance) {
        sharedInstance = [[GameModel alloc] init];
    }
    return sharedInstance;
}

- (id)init {
    if((self=[super init])) {
        
        self->_elements = [NSMutableArray array];
        self->_worldWidth = kWorldWidth;
        self->_worldHeight = kWorldHeight;
        
        // Create a world in Box2D
        b2Vec2 gravity = b2Vec2(0.0f, -10.0f);
        self->_world = new b2World(gravity);
        
        // Create the floor along the bottom
        b2BodyDef groundBodyDef;
        groundBodyDef.position.Set(0,0);
        
        b2Body *groundBody = _world->CreateBody(&groundBodyDef);
        b2EdgeShape groundEdge;
        b2FixtureDef boxShapeDef;
        boxShapeDef.shape = &groundEdge;
        groundEdge.Set(b2Vec2(0,0), b2Vec2(self->_worldWidth, 0));
        groundBody->CreateFixture(&boxShapeDef);
        //
        // from www.box2d.org/manual.html:
        // Box2D does not keep a reference to the shape. It clones the data into a new b2Shape object.
        //
        
        //
        //  Let the outside world know there is a model
        //
        [[NSNotificationCenter defaultCenter] postNotificationName:@"registerModel" object:self];
    }
    return self;
}

#pragma mark - Helper routines

-(void) addElement:(GameElement*)element {
    [_elements addObject:element];
}


#pragma mark - Set up routines

- (void) createGameObjects {
    
    GameElement* element;
    element = [GameElement elementNamed:@"grassbehind" at:Point3DMake(self.worldWidth/2., 0.3, 0.) inModel:self];
    element.scale = 1.08;
    [self addElement:element];

    NSArray* animalNames = @[@"bear", @"monkey"];
    for (int i=0; i<randBetween(4, 8); i++) {
            Animal* animal = [Animal animalNamed:animalNames[randIntBetween(0, animalNames.count)] at:Point3DMake(rand0to1*self.worldWidth,rand0to1*self.worldHeight,0.) inModel:self];
        [self addElement:animal];
    }

    element = [GameElement elementNamed:@"grassfront" at:Point3DMake(0, 0.1, 0.) inModel:self];
    element.scale = 1.08;
    [self addElement:element];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"reviseElements" object:self];
}

#pragma mark - Exposed methods

- (int) countElements {
    return self.elements.count;
}

- (BOOL) containsElement:(GameElement*)element {
    return [self.elements containsObject:element];
}

#pragma mark - Box2D

- (b2Body*) createBody:(b2BodyDef*)bodyDefPtr {
    return self.world->CreateBody(bodyDefPtr);
}

#pragma mark - Updatable protocol

-(void) update:(ccTime)dt {
    //
    // Update physics
    //

    self.world->Step(dt, 8, 6);
    
    //
    // And do any extra element-specific updates
    //
    
    for (GameElement* element in self.elements) {
        [element update:dt];
    }
}



@end
