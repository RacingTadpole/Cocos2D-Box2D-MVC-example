//
//  GameController.m
//
//  Created by Arthur Street on 15/10/12.
//
//  The game controller:
//     - initialises the view and the model
//     - is the scene for the view
//     - handles touches etc
//
//  See http://xperienced.com.pl/blog/how-to-implement-mvc-pattern-in-cocos2d-gamepart-2 for inspiration
//

#import "GameController.h"
#import "GameView.h"
#import "GameModel.h"
#import "cocos2d.h"

@interface GameController() {
    GameView *view;
}
@end

@implementation GameController

- (id)init {
    if((self=[super init])) {
        // init view
        self->view = [[GameView alloc] initWithDelegate:self];
        
        // init model
        GameModel *model = [GameModel sharedModel];
        
        // setup the game
        [model createGameObjects];
        
        //[model.player run];
        
        [self scheduleUpdate]; // kicks off the game loop so that update is called every dt
    }
    return self;
}

- (void)update:(ccTime) dt {
    GameModel *model = [GameModel sharedModel];
    
//    if (model.isGameOver) {
//        [[CCDirector sharedDirector] replaceScene:[GameOverController node]];
//    }
    
    // update model
    [model update:dt];
    
    // update view
    [view update:dt];
}

@end
