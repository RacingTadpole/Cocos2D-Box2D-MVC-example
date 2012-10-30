//
//  HelloWorldLayer.h
//


#import <GameKit/GameKit.h>
#import "cocos2d.h"

@interface HelloWorldLayer : CCLayer <GKLeaderboardViewControllerDelegate>


+(CCScene *) scene;  // returns a CCScene that contains the HelloWorldLayer as the only child

@end
