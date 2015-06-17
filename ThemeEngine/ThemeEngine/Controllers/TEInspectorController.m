//
//  TEInspectorController.m
//  ThemeEngine
//
//  Created by Alexander Zielenski on 6/15/15.
//  Copyright © 2015 Alex Zielenski. All rights reserved.
//

#import "TEInspectorController.h"

@interface TEFlippedClipView : NSClipView
@end

@implementation TEFlippedClipView

- (BOOL)isFlipped {
    return YES;
}

@end

@interface TEInspectorController ()
@property (strong) IBOutlet NSScrollView *scrollView;
- (void)reevaluatedVisibility;
@end

const void *kTEInspectorControllerSelectionDidChange = &kTEInspectorControllerSelectionDidChange;

@implementation TEInspectorController

- (void)awakeFromNib {
    if (!self.view) {
        [self loadView];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
     self.inspectorViewControllers = @[
                                       self.gradientInspector,
                                       self.attributesInspector
                                       ];
    
    NSView *view = self.contentView;
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints"];
    self.scrollView.documentView = view;
    [self.scrollView.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[view]-0-|"
                                                                                        options:0
                                                                                        metrics:nil
                                                                                          views:NSDictionaryOfVariableBindings(view)]];
    
    for (NSViewController *vc in self.inspectorViewControllers) {
        [self.contentView addView:vc.view inGravity:NSStackViewGravityTop];
    }

    [self addObserver:self forKeyPath:@"representedObject.selection" options:0 context:&kTEInspectorControllerSelectionDidChange];
    [self reevaluatedVisibility];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary *)change context:(nullable void *)context {
    if (context == &kTEInspectorControllerSelectionDidChange) {
        [self reevaluatedVisibility];
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)reevaluatedVisibility {
    for (TEInspectorDetailController *vc in self.inspectorViewControllers) {
        NSStackViewVisibilityPriority vp = [vc visibilityPriorityForInspectedObjects:[self valueForKeyPath:@"representedObject.selectedObjects"]];
        [self.contentView setVisibilityPriority:vp
                                        forView:vc.view];
    }
}

@end