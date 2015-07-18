//
//  IWUIConstants.h
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 17/05/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


//COLOUR THEME

#define COLOR_NAV_BAR [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0]
#define COLOR_VIEW_BG [UIColor whiteColor]//[UIColor colorWithRed:255.0/255.0 green:235.0/255.0 blue:205.0/255.0 alpha:1.0]
#define COLOR_MARKDOWN_VIEW_BG [UIColor whiteColor]//[UIColor colorWithRed:235.0/255.0 green:215.0/255.0 blue:185.0/255.0 alpha:1.0]
#define COLOR_TITLE_VIEW [UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0]
#define COLOR_SECTION_HEADER [UIColor colorWithRed:64.0/255 green:64.0/255 blue:64.0/255 alpha:1.0]
#define COLOR_SECTION_HEADER_TITLE [UIColor whiteColor]//[UIColor colorWithRed:255.0/255.0 green:245.0/255.0 blue:215.0/255.0 alpha:1.0]
#define COLOR_LOADING_VIEW [UIColor blackColor]//[UIColor colorWithRed:52.0/255.0 green:26.0/255.0 blue:0.0/255.0 alpha:1.0]

/******* Storyboard Names *******/

#define STORYBOARD_MAIN @"Main"
#define STORYBOARD_LEFT_DRAWER @"LeftDrawer"
#define STORYBOARD_COMPILATION @"Compilation"
#define STORYBOARD_VOLUME @"Volume"
#define STORYBOARD_CHAPTER @"Chapter"
#define STORYBOARD_ABOUT @"About"
#define STORYBOARD_DICTIONARY @"Dictionary"
#define STORYBOARD_POPOVER @"Popover"

/*******************************/







/******* Storyboard view id *******/



///////////////// MAIN ///////////////

//Home view
#define S_MAIN_ID_HOME_VC @"HOME_VC"

//Root navigation view

#define S_MAIN_ID_CENTER_NAVIGATION_VC @"CENTER_NAVIGATION_VC"

#define S_MAIN_ID_CAROUSEL_ITEM_VC @"CAROUSEL_ITEM_VC"

///////////////// LEFT DRAWER ///////////////

//Left Drawer
#define S_LEFT_ID_LEFT_DRAWER_VC @"LEFT_DRAWER_VC"


///////////////// COMPILATIONS ///////////////

#define S_COMP_COMPILATION_VC @"COMPILATION_VC"


///////////////// VOLUME ///////////////

#define S_VOL_VOLUME_DETAILS_VC @"VOLUME_DETAILS_VC"

///////////////// CHAPTER ///////////////

#define S_CHAP_CHAPTER_DETAILS_VC @"CHAPTER_DETAILS_VC"

///////////////// ABOUT ///////////////

#define S_ABOUT_ABOUT_VC @"ABOUT_VC"

///////////////// ABOUT ///////////////

#define S_DICTIONARY_DICTIONARY_VC @"DICTIONARY_VC"

#define S_DICTIONARY_DICTIONARY_MEANING_VC @"DICTIONARY_MEANING_VC"

///////////////// POPOVER ///////////////


#define S_POPOVER_INFO_VC @"INFO_VC"


/*******************************/


#define FONT_TITLE_REGULAR @"CharlotteSansW02-Book"
#define FONT_TITLE_MEDIUM @"CharlotteSansW02-Medium"
#define FONT_TITLE_ITALIC @"CharlotteSansW02-BookItalic"


#define FONT_BODY_BOLD @"MonotypeSabonW04-SemiBold"
#define FONT_BODY_ITALIC @"MonotypeSabonW04-Italic"
#define FONT_BODY_REGULAR @"MonotypeSabonW04-Regular"
#define FONT_BODY_SEMIBOLD_ITALIC @"MonotypeSabonW04-SemiBdItal"


/*****************************/


#define STR_WEB_SERVICE_FAILED @"Unable to connect to server              ."
#define STR_NO_NETWORK_ALERT_TITLE @"Error"
#define STR_NO_NETWORK_ALERT_MESSAGE @"Could not connect to server. Please check network connection and try again later."

