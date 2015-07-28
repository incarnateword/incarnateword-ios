//
//  IWDetailChapterStructure.h
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 17/05/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IWDetailChapterStructure : NSObject

/*
 {
 "chapter": {
 "desc": "This letter was written by Sri Aurobindo after his acquittal in the Alipore Conspiracy Case, in view of a public appeal which had been issued by his sister Sarojini Ghose for funds to defend him.",
 "dt": "1909-05-14",
 "nxtt": "The Ideal of the Karmayogin",
 "nxtu": "/sabcl/02/the-ideal-of-the-karmayogin",
 "path": [
 {
 "t": "SABCL",
 "u": "/sabcl"
 },
 {
 "t": "Karmayogin",
 "u": "/sabcl/02"
 }
 ],
 "t": "Letter to the Editor of the Bengalee",
 "url": "/sabcl/02/letter-to-the-editor-of-the-bengalee",
 "text": "Sir,\n\nWill you kindly allow me to express through your columns my deep sense of gratitude to all who have helped me in my hour of trial? Of the innumerable friends known and unknown, who have contributed each his mite to swell my defence fund, it is impossible for me now even to learn the names, and I must ask them to accept this public expression of my feeling in place of private gratitude; since my acquittal many telegrams and letters have reached me and they are too numerous to reply to individually. The love which my countrymen have heaped upon me in return for the little I have been able to do for them, amply repays any apparent trouble or misfortune my public activity may have brought upon me. I attribute my escape to no human agency, but first of all to the protection of the Mother of us all who has never been absent from me but always held me in Her arms and shielded me from grief and disaster, and secondarily to the prayers of thousands which have been going up to Her on my behalf ever since I was arrested. If it is the love of my country which led me into danger, it is also the love of my countrymen which has brought me safe through it.\n\nAurobindo Ghose\n6, College Square, May 14, 1909"
 }
 }
 */

@property(readwrite) NSString   *strDescription;
@property(readwrite) NSString   *strDate;
@property(readwrite) NSString   *strNextChapter;
@property(readwrite) NSString   *strNextChapterUrl;
@property(readwrite) NSString   *strPrevChapter;
@property(readwrite) NSString   *strPrevChapterUrl;
@property(readwrite) NSArray    *arrPath;
@property(readwrite) NSString   *strTitle;
@property(readwrite) NSString   *strUrl;
@property(readwrite) NSString   *strText;


@end
