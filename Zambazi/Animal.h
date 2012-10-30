//
//  Animal.h
//
//  Created by Arthur Street on 17/10/12.
//

#import <Foundation/Foundation.h>
#import "GameElement_Private.h"

@interface Animal : GameElement

@property BOOL moving;
@property (nonatomic, strong) NSString* behaveName;

-(id) initWithName:(NSString*)appearName at:(Point3D)where inModel:(GameModel*)model;
+(Animal*) animalNamed:(NSString*)appearName at:(Point3D)where inModel:(GameModel*)model;

@end
