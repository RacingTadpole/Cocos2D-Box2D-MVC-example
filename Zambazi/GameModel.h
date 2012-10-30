//
//  GameModel.h
//
//  Created by Arthur Street on 17/10/12.
//

#import <Foundation/Foundation.h>
#include <Box2D/Box2D.h>
#import "Animal.h"

@interface GameModel : NSObject <Updatable>

@property (nonatomic, readwrite) float worldWidth, worldHeight;
@property (nonatomic, strong) NSMutableArray* elements;

+ (GameModel*) sharedModel;
- (void) createGameObjects;

- (int) countElements;
- (BOOL) containsElement:(GameElement*)element;

- (b2Body*) createBody:(b2BodyDef*)bodyDef; // Box2D - this creates the body and attaches it to the world


@end
