//
//  PhotonDefines.h
//  Photon
//
//  Created by Logan Collins on 12/15/11.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#define PHOTON_EXTERN extern __attribute__((visibility("default")))

#define PHOTON_EXPORT PHOTON_EXTERN
#define PHOTON_IMPORT PHOTON_EXTERN

#define PHOTON_CLASS_AVAILABLE(intro) __attribute__((visibility("default"))) NS_CLASS_AVAILABLE(intro, NA)
