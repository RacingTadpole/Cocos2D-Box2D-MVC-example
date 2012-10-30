//
//  GameElement.m
//
//  Created by Arthur Street on 25/10/12.
//
//

#import "GameElement.h"
#import "GameModel.h"

@interface GameElement () {
}

@end

@implementation GameElement

#pragma mark Initialization

-(id) init {
    if((self = [super init])) {
        self->_scale = 1.;
    }
    return self;
}

-(id) initWithName:(NSString*)appearName at:(Point3D)where inModel:(GameModel*)model {
    if((self = [super init])) {
        //
        // set the identifier properties
        //
        self->_scale = 1.;
        self->_appearName = appearName;
        //
        // set the physical properties
        //
        [self makeBodyAt:where inModel:model];
    }
    return self;

}

+(GameElement*) elementNamed:(NSString*)appearName at:(Point3D)where inModel:(GameModel*)model {
    GameElement* element = [[GameElement alloc] initWithName:appearName at:where inModel:model];
    return element;
}

#pragma mark Setup

-(void) makeBodyAt:(Point3D)where inModel:(GameModel*)model {
    //
    // set the physical properties.
    // override this in subclasses
    //
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody; 
    bodyDef.position.Set(where.x, where.y);
    self.body = [model createBody:&bodyDef];
    NSLog(@"Created generic body for %@ ptr %p at (%6.2f,%6.2f)", self.appearName, self.body, where.x, where.y);
    
    b2CircleShape circle;
    circle.m_radius = 0.4; // for now
    
    b2FixtureDef shapeDef;
    shapeDef.shape = &circle;
    shapeDef.density = 1.0f;
    shapeDef.friction = 0.2f;
    shapeDef.restitution = 0.8f;
    
    self.body->CreateFixture(&shapeDef);
}


#pragma mark Exposed functions


-(void) applyImpulseToVelocity:(Point3D)targetVelocity {
    b2Vec2 vel = self.body->GetLinearVelocity();
    float dvx = targetVelocity.x - vel.x;
    float dvy = targetVelocity.y - vel.y;
    float mass = self.body->GetMass();
    self.body->ApplyLinearImpulse( b2Vec2(mass * dvx,mass * dvy), self.body->GetWorldCenter() );
}

-(Point3D) where {
    b2Vec2 vec = self.body->GetPosition();
    return Point3DMake(vec.x, vec.y, 0.);
}

-(Point3D) velocity {
    b2Vec2 vec = self.body->GetLinearVelocity();
    return Point3DMake(vec.x, vec.y, 0.);
}


#pragma mark Updatable protocol

//
// Subclasses need to define how elements update.
// The default is to do nothing.
//
-(void) update:(ccTime)dt {
}


//
// This implementation of copyWithZone implies the GameElement is "immutable",
// so we can pass the same game element back as the copy.
//
// I do this so that GameElements can be used as keys in NSDictionary.
// http://stackoverflow.com/questions/2394083/cocoas-nsdictionary-why-are-keys-copied
//
-(id)copyWithZone:(NSZone *)zone {
    return self;
}

@end
