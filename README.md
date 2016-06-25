# PATabbarView

[![CI Status](http://img.shields.io/travis/Inba/PATabbarView.svg?style=flat)](https://travis-ci.org/Inba/PATabbarView)
[![Version](https://img.shields.io/cocoapods/v/PATabbarView.svg?style=flat)](http://cocoapods.org/pods/PATabbarView)
[![License](https://img.shields.io/cocoapods/l/PATabbarView.svg?style=flat)](http://cocoapods.org/pods/PATabbarView)
[![Platform](https://img.shields.io/cocoapods/p/PATabbarView.svg?style=flat)](http://cocoapods.org/pods/PATabbarView)

![header:YES mid:NO](./SampleImages/sampleGif.gif "header:YES mid:NO")  

## Usage
If you want to try it, simply run:

```ruby
pod try PATabbarView
```

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

PATabbarView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "PATabbarView"
```


# How to

1.Add PATabbarView To Interface.

2.Make PATabbarPushedView,and call addToTailView: in addition to this as an argument

    UINib *nib = [UINib nibWithNibName:@"PATabbarPushedView" bundle:nil];
    PATabbarPushedView *pushedView=  [nib instantiateWithOwner:nil options:nil][0]; 
    [self.tabbarView addToTailView:pushedView];

    
# Delete pushedView From tabbarView.
If call deleteView:, Argument view is deleted from PATabbarView with delete and reposition animation.
PushedView must be in subview of PATabbarPushedView.

`[self.tabbarView deleteView:pushedView];`


# Reposition pushedView.
If call adjustPositionWithAForcusOnView:,Pushed views reposition With A Forcus On argument view with a animation.

`[self.tabbarView adjustPositionWithAForcusOnView:centerPushedView];`


# Design pushedView

You can applie autolayout and autosize to PATabbarPushedView obj.
You had better use autolayout with nib.(Possible in other ways! maybe..)

#Requirements

・Xcode 7.0 or greater

・iOS8.0 or greater

## Author

Inba, gyuuuuchan@gmail.com

## License

PATabbarView is available under the MIT license. See the LICENSE file for more info.
