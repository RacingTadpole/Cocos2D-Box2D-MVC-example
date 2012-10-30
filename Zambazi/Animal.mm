//
//  Animal.m
//
//  Created by Arthur Street on 17/10/12.
//

#import "Animal.h"
#import "GameElement_Private.h"
#import "GameModel.h"

@implementation Animal

#pragma mark Initialization

-(id) init {
    if((self = [super init])) {
        self->_moving = NO;
    }
    return self;
}

-(id) initWithName:(NSString*)appearName at:(Point3D)where inModel:(GameModel*)model {
    if((self = [super initWithName:appearName at:where inModel:model])) {
        self->_moving = NO;
        self->_behaveName = appearName;
    }
    return self;
}

+(Animal*) animalNamed:(NSString*)appearName at:(Point3D)where inModel:(GameModel*)model {
    Animal* animal = [[Animal alloc] initWithName:appearName at:where inModel:model];
    return animal;
}

#pragma mark Setup

-(void) makeBodyAt:(Point3D)where inModel:(GameModel*)model {
    //
    // set the physical properties.
    // overrides the base class
    //
    b2BodyDef ballBodyDef;
    ballBodyDef.type = b2_dynamicBody;
    ballBodyDef.position.Set(where.x, where.y);
    self.body = [model createBody:&ballBodyDef];
    NSLog(@"Created animal body for %@ ptr %p at (%6.2f,%6.2f)", self.appearName, self.body, where.x, where.y);
    
    b2CircleShape circle;
    circle.m_radius = 0.4; // for now
    
    b2FixtureDef ballShapeDef;
    ballShapeDef.shape = &circle;
    ballShapeDef.density = 1.0f;
    ballShapeDef.friction = 0.2f;
    ballShapeDef.restitution = 0.8f;
    
    self.body->CreateFixture(&ballShapeDef);
}


#pragma mark Updatable protocol

//-(void) update:(ccTime)dt {
//    if (_moving) {
//        [self moveByDx:_velocity.x*dt dy:_velocity.y*dt dz:_velocity.z*dt];
//    }
//}


@end
