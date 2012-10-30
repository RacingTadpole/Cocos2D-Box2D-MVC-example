//
//  Utils.h
//
//  Created by Arthur Street on 17/10/12.
//

#import "cocos2d.h"

#define randBetween(a,b) (((float) rand() / RAND_MAX) * (b - a) + a)
#define randIntBetween(a,b) ((int) randBetween(a,b))
#define rand0to1 ((float) rand() / RAND_MAX)

typedef struct Point3D_ {
    CGFloat x, y, z;
} Point3D;

Point3D Point3DMake(CGFloat xx, CGFloat yy, CGFloat zz);
void    Point3DAdd(Point3D *p, CGFloat xx, CGFloat yy, CGFloat zz);

@protocol Updatable
-(void) update:(ccTime)dt;
@end
