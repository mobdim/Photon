//
//  NSObject+PhotonAdditions.h
//  Photon
//
//  Created by Logan Collins on 8/14/12.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import <Foundation/NSObject.h>


@interface NSObject (PhotonAdditions)

/*!
 * @method px_addObserver:forKeyPaths:options:context:
 * @abstract Add a KVO observer for multiple key paths
 * 
 * @param observer
 * The object for which to add observations
 * 
 * @param keyPaths
 * The key paths for which to add observations
 * 
 * @param context
 * The context to use for the observations
 * 
 * @discussion
 * This is a convenience wrapper for adding a KVO observer for multiple key paths simultaneously
 */
- (void)px_addObserver:(NSObject *)observer forKeyPaths:(NSSet *)keyPaths options:(NSKeyValueObservingOptions)options context:(void *)context;

/*!
 * @method px_removeObserver:forKeyPaths:
 * @abstract Remove a KVO observer for multiple key paths
 *
 * @param observer
 * The object for which to remove observations
 *
 * @param keyPaths
 * The key paths for which to remove observations
 * 
 * @discussion
 * This is a convenience wrapper for removing a KVO observer for multiple key paths simultaneously
 */
- (void)px_removeObserver:(NSObject *)observer forKeyPaths:(NSSet *)keyPaths;

/*!
 * @method px_removeObserver:forKeyPaths:context:
 * @abstract Remove a KVO observer for multiple key paths
 * 
 * @param observer
 * The object for which to remove observations
 * 
 * @param keyPaths
 * The key paths for which to remove observations
 * 
 * @param context
 * The context used for the observations
 * 
 * @discussion
 * This is a convenience wrapper for removing a KVO observer for multiple key paths simultaneously
 */
- (void)px_removeObserver:(NSObject *)observer forKeyPaths:(NSSet *)keyPaths context:(void *)context;

@end
