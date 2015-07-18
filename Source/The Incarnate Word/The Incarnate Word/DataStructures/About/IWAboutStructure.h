//
//  IWAboutStructure.h
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 30/05/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IWAboutStructure : NSObject
/*
 
 {
 "author": {
 "auth": "sa",
 "autn": "Sri Aurobindo",
 "comp": [
 {
 "t": "The Complete Works of Sri Aurobindo",
 "u": "cwsa"
 },
 {
 "t": "Sri Aurobindo Birth Centenary Library",
 "u": "sabcl"
 }
 ],
 "desc": "What Sri Aurobindo represents in the world's history is not a teaching, not even a revelation; it is a decisive action direct from the Supreme.\n\n---\n\nSri Aurobindo has come on earth not to bring a teaching or a creed in competition with previous creeds or teachings, but to show the way to overpass the past and to open concretely the route towards an imminent and inevitable future.\n\n---\n\nSri Aurobindo came upon earth to teach this truth to men. He told them that man is only a transitional being living in a mental consciousness, but with the possibility of acquiring a new consciousness, the Truth-consciousness, and capable of living a life perfectly harmonious, good and beautiful, happy and fully conscious. During the whole of his life upon earth, Sri Aurobindo gave all his time to establish in himself this consciousness he called supramental, and to help those gathered around him to realise it.",
 "dest": "The Mother on Sri Aurobindo"
 }
 }
 
 */

@property(readwrite) NSString *strAutherName;
@property(readwrite) NSString *strDescriptionTitle;
@property(readwrite) NSString *strDescription;
@property(readwrite) NSArray *arrCompilations;

@end
