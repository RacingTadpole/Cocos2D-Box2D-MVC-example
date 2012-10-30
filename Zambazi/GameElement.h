//
//  GameElement.h
//
//  Created by Arthur Street on 25/10/12.
//
//

#import <Foundation/Foundation.h>
#import "Utils.h"
#include <Box2d/Box2D.h>

@class GameModel;

@interface GameElement : NSObject <NSCopying, Updatable>

@property (readwrite) float scale;
@property (nonatomic, strong) NSString* appearName;
@property (readwrite) b2Body* body;

-(id) initWithName:(NSString*)appearName at:(Point3D)where inModel:(GameModel*)model;
+(GameElement*) elementNamed:(NSString*)appearName at:(Point3D)where inModel:(GameModel*)model;

-(Point3D) where;
-(Point3D) velocity;
-(void) applyImpulseToVelocity:(Point3D)targetVelocity;

@end
