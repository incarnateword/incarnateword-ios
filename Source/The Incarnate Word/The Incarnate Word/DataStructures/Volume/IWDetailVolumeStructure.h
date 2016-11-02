//
//  IWDetailVolumeStructure.h
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 17/05/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IWDetailVolumeStructure : NSObject

/*
 
 {
 "volume": {
 "_id": {
 "$oid": "554d2c4469702d4f306d0100"
 },
 "alt": "Bande Mataram",
 "auth": "sa",
 "autn": "Sri Aurobindo",
 "cmpa": "SABCL",
 "cmpn": "Sri Aurobindo Birth Centenary Library",
 "comp": "sabcl",
 "curl": "sabcl",
 
 "nxtt": "The Harmony of Virtue",
 "nxtu": "/sabcl/03",
 "nxtv": 3,
 
 "prvt": "Bande Mataram",
 "prvu": "/sabcl/01",
 "prvv": 1,
 
 "subt": "Early Political Writings - 1 (1890-May 1908)",
 "t": "Bande Mataram",
 "toc": {
 "parts": [
 {
 "partt": "1890-1905",
 "chapters": [
 {
 "chapt": "Notes and Comments",
 "u": "notes-and-comments",
 "items": [
 {
 "itemt": "The Message of India",
 "u": "notes-and-comments#the-message-of-india"
 }]
 }]
 }
 ,
 {
 "partt": "Second Series",
 "sections": [
 {
 "sect": "The Synthesis of Works, Love and Knowledge",
 "sec": "Part I",
 "chapters": [
 {
 "chapt": "The Two Natures",
 "chap": "Chapter I",
 "u": "the-two-natures"
 },
 {
 "chapt": "The Synthesis of Devotion and Knowledge",
 "chap": "Chapter II",
 "u": "the-synthesis-of-devotion-and-knowledge"
 },
 {
 "chapt": "The Supreme Divine",
 "chap": "Chapter III",
 "u": "the-supreme-divine"
 }
 ]
 }
 
 
 
 */

@property(nonatomic) NSString   *strIndex;// "vol": 1
@property(nonatomic) NSString   *strTitle;//"alt": "Bande Mataram",
@property(nonatomic) NSString   *strCompilationAuther;// "cmpa": "SABCL",
@property(nonatomic) NSString   *strCompilationName;// "cmpn": "Sri Aurobindo Birth Centenary Library",
@property(nonatomic) NSString   *strSubTitle;//"subt": "Early Political Writings - 1 (1890-May 1908)",
@property(nonatomic) NSArray    *arrBooks;
@property(nonatomic) NSArray    *arrParts;
@property(nonatomic) NSArray    *arrChapters;
@property(nonatomic) NSString   *strUrlNextVolume;
@property(nonatomic) NSString   *strUrlPrevVolume;
@property(nonatomic) NSString   *strUrlCurrentVolume;
@end
