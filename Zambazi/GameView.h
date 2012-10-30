//
//  GameView.h
//
//  Created by Arthur Street on 15/10/12.
//

#import "CCNode.h"
#import "Utils.h"

@class GameModel;

@interface GameView : CCNode <Updatable>

- (id)initWithDelegate:(id)theDelegate;

@end
