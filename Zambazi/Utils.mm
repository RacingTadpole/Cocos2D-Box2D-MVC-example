//
//  Utils.m
//
//  Created by Arthur Street on 17/10/12.
//

#import "Utils.h"

Point3D Point3DMake(CGFloat xx, CGFloat yy, CGFloat zz) {
    Point3D p;  
    p.x = xx; p.y = yy; p.z = zz;
    return p;
}

void Point3DAdd(Point3D *p, CGFloat xx, CGFloat yy, CGFloat zz) {
    (*p).x += xx;
    (*p).y += yy;
    (*p).z += zz;
}
