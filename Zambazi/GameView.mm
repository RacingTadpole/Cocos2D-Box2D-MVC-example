//
//  GameView.m
//
//  Created by Arthur Street on 15/10/12.
//

#import "GameView.h"
#import "GameLayer.h"
#import "GameModel.h"

@interface GameView () {
    id delegate;  // to do - add protocol
    NSMutableSet* updatableLayers;  // keep track of the layers that need updating
}

@end

@implementation GameView

- (id)initWithDelegate:(id)theDelegate {
    if ((self = [super init])) {
        self->delegate = theDelegate;
        self->updatableLayers = [NSMutableSet set];
        
        // initialize layers
        GameLayer *layer = [GameLayer node];
        [self->delegate addChild: layer];
        [self->updatableLayers addObject:layer];
        
//        _backgroundLayer = [GameplayBackgroundLayer node];
//        [self.delegate addChild: _backgroundLayer];
//        
//        _platformLayer = [GameplayPlatformLayer node];
//        [self.delegate addChild:_platformLayer];
//        
//        _playerLayer = [GameplayPlayerLayer node];
//        _playerLayer.delegate = theDelegate;
//        [self.delegate addChild: _playerLayer];
//        
//        _hudLayer = [GameplayHudLayer node];
//        _hudLayer.delegate = theDelegate;
//        [self.delegate addChild:_hudLayer];
    }
    
    return self;
}

- (void)update:(ccTime) dt {
    for (CCLayer<Updatable>* layer in updatableLayers) {
        [layer update:dt];
    }
}

@end
