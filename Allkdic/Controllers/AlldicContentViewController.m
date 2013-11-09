//
//  AlldicContentViewController.m
//  Allkdic
//
//  Created by 전수열 on 13. 8. 6..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "AlldicContentViewController.h"
#import "AllkdicController.h"

@implementation AlldicContentViewController

- (void)awakeFromNib
{
	self.webView.mainFrameURL = @"http://dic.daum.net/index.do?dic=eng";
//	self.webView.mainFrameURL = @"http://endic.naver.com/popManager.nhn?m=miniPopMain";
	[self.indicator startAnimation:nil];
}

- (void)updateHotKeyLabel
{
	KeyBinding *keyBinding = [KeyBinding keyBindingWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:AllkdicSettingKeyHotKey]];
	NSMutableArray *keys = [NSMutableArray array];
	if( keyBinding.shift ) {
		[keys addObject:@"Shift"];
	}
	if( keyBinding.option ) {
		[keys addObject:@"Option"];
	}
	if( keyBinding.control ) {
		[keys addObject:@"Control"];
	}
	if( keyBinding.command ) {
		[keys addObject:@"Command"];
	}
	[keys addObject:[[KeyBinding keyStringFormKeyCode:keyBinding.keyCode] capitalizedString]];
	self.hotKeyLabel.stringValue = [keys componentsJoinedByString:@" + "];
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
	[self.indicator stopAnimation:nil];
	[self focusOnTextArea];
}

- (void)focusOnTextArea
{
	[self javascript:@"q.focus()"];
	[self javascript:@"q.select()"];
}

- (void)handleKeyBinding:(KeyBinding *)keyBinding
{
	// Esc
	if( !keyBinding.shift && !keyBinding.control && !keyBinding.option && !keyBinding.command && keyBinding.keyCode == 53 )
	{
		[[AllkdicController sharedController] close];
	}
	
	// Command + A
	else if( !keyBinding.shift && !keyBinding.control && !keyBinding.option && keyBinding.command && keyBinding.keyCode == [KeyBinding keyCodeFormKeyString:@"a"] )
	{
		[self focusOnTextArea];
	}
	
	// Command + X
	else if( !keyBinding.shift && !keyBinding.control && !keyBinding.option && keyBinding.command && keyBinding.keyCode == [KeyBinding keyCodeFormKeyString:@"x"] )
	{
		NSString *input = [self javascript:@"q.value.slice(q.selectionStart, q.selectionEnd)"];
		[[NSPasteboard generalPasteboard] clearContents];
		[[NSPasteboard generalPasteboard] setString:input forType:NSStringPboardType];
		NSLog( @"'%@' has been copied.", input );
		
		NSMutableString *script = [NSMutableString string];
		[script appendString:@"var selection = q.selectionStart;"];
		[script appendString:@"q.value = q.value.substring(0, q.selectionStart) + q.value.substr(q.selectionEnd,  q.value.length - q.selectionEnd);"];
		[script appendString:@"q.selectionStart = q.selectionEnd = selection;"];
		[self javascript:script];
	}
	
	// Command + C
	else if( !keyBinding.shift && !keyBinding.control && !keyBinding.option && keyBinding.command && keyBinding.keyCode == [KeyBinding keyCodeFormKeyString:@"c"] )
	{
		NSString *input = [self javascript:@"q.value.slice(q.selectionStart, q.selectionEnd)"];
		[[NSPasteboard generalPasteboard] clearContents];
		[[NSPasteboard generalPasteboard] setString:input forType:NSStringPboardType];
		NSLog( @"'%@' has been copied.", input );
	}
	
	// Command + V
	else if( !keyBinding.shift && !keyBinding.control && !keyBinding.option && keyBinding.command && keyBinding.keyCode == [KeyBinding keyCodeFormKeyString:@"v"] )
	{
		NSString *input = [[NSPasteboard generalPasteboard] stringForType:NSStringPboardType];
		if( !input ) return;
		
		NSMutableString *script = [NSMutableString string];
		[script appendFormat:@"var input = '%@';", input];
		[script appendString:@"var selection = q.selectionStart + input.length;"];
		[script appendString:@"q.value = q.value.substring(0, q.selectionStart) + input + q.value.substr(q.selectionEnd,  q.value.length - q.selectionEnd);"];
		[script appendString:@"q.selectionStart = q.selectionEnd = selection;"];
		[self javascript:script];
	}
}

- (id)javascript:(NSString *)javascript
{
	return [self.webView.mainFrameDocument evaluateWebScript:javascript];
}


- (IBAction)showMenu:(id)sender
{
	[self.menu popUpMenuPositioningItem:[self.menu itemAtIndex:0] atLocation:self.menuButton.frame.origin inView:self.view];
}

- (IBAction)showPreferenceWindow:(id)sender
{
	[[AllkdicController sharedController].preferenceWindowController showWindow:self];
}

- (IBAction)showAboutWindow:(id)sender
{
	[[AllkdicController sharedController].aboutWindowController showWindow:self];
}

- (IBAction)quit:(id)sender
{
	[NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:0.0];
}

@end
