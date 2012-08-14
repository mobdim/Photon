//
//  PhotonDefines.h
//  Photon
//
//  Created by Logan Collins on 8/14/12.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//


#define PHOTON_EXTERN extern __attribute__((visibility("default")))
#define PHOTON_INLINE static inline __attribute__((visibility("default")))

#if (__has_feature(objc_fixed_enum))
#define PHOTON_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#define PHOTON_OPTIONS(_type, _name) enum _name : _type _name; enum _name : _type
#else
#define PHOTON_ENUM(_type, _name) _type _name; enum
#define PHOTON_OPTIONS(_type, _name) _type _name; enum
#endif
