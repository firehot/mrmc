/*
 *      Copyright (C) 2018 Team MrMC
 *      https://github.com/MrMC
 *
 *  This Program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2, or (at your option)
 *  any later version.
 *
 *  This Program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with MrMC; see the file COPYING.  If not, see
 *  <http://www.gnu.org/licenses/>.
 *
 */

#import "platform/darwin/tvos/FocusLayerViewSlider.h"
#import "platform/darwin/NSLogDebugHelpers.h"
#import "utils/log.h"

#pragma mark -
@implementation FocusLayerViewSlider

  double animationSpeed = 1.0;
  CGFloat decelerationRate = 0.92;
  CGFloat decelerationMaxVelocity = 1000;

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
    self->min = 0.0;
    self->max = 100.0;
    self->value = 0.0;
    self->distance = 100;

    auto pan = [[UIPanGestureRecognizer alloc]
      initWithTarget:self action:@selector(handlePanGesture:)];
    pan.delegate = self;
    [self addGestureRecognizer:pan];

    auto tapRecognizer = [[UITapGestureRecognizer alloc]
      initWithTarget: self action: @selector(handleTapGesture:)];
    tapRecognizer.delegate  = self;
    [self addGestureRecognizer:tapRecognizer];
  }
	return self;
}

- (void)set:(double)value animated:(bool)animated
{
  [self stopDeceleratingTimer];
  if (distance == 0.0)
  {
    self->value = value;
    return;
  }
  double duration = fabs(self->value - value) / distance * animationSpeed;
  self->value = value;
  if (animated)
  {
    [UIView animateWithDuration:duration
     animations:^{
      [self setNeedsLayout];
      [self layoutIfNeeded];
    }
    completion:^(BOOL finished){ }];
  }
  else
  {
    self->value = value;
  }
}

- (void)drawRect:(CGRect)rect
{
  [super drawRect:rect];
}

- (void)didUpdateFocusInContext:(UIFocusUpdateContext *)context
    withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator
{
  CLog::Log(LOGDEBUG, "Slider::didUpdateFocusInContext");
  [super didUpdateFocusInContext:context withAnimationCoordinator:coordinator];
  if (context.nextFocusedView == self)
  {
    /*
    coordinator.addCoordinatedAnimations({ () -> Void in
        self.seekerView.transform = CGAffineTransform(translationX: 0, y: -12)
        self.seekerLabelBackgroundInnerView.backgroundColor = .white
        self.seekerLabel.textColor = .black
        self.seekerLabelBackgroundView.layer.shadowOpacity = 0.5
        self.seekLineView.layer.shadowOpacity = 0.5
        }, completion: nil)
    */
  }
  else if (context.previouslyFocusedView == self)
  {
    /*
    coordinator.addCoordinatedAnimations({ () -> Void in
        self.seekerView.transform = .identity
        self.seekerLabelBackgroundInnerView.backgroundColor = .lightGray
        self.seekerLabel.textColor = .white
        self.seekerLabelBackgroundView.layer.shadowOpacity = 0
        self.seekLineView.layer.shadowOpacity = 0
        }, completion: nil)
    */
  }
}

//--------------------------------------------------------------
- (IBAction)handleTapGesture:(UITapGestureRecognizer *)sender
{
  CLog::Log(LOGDEBUG, "Slider::handleTapGesture");
  [self stopDeceleratingTimer];
  //[delegate sliderDidTap:self];
}

//--------------------------------------------------------------
- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)sender
{
  CLog::Log(LOGDEBUG, "Slider::handlePanGesture");
  CGPoint translation = [sender translationInView:self];
  CGPoint velocity =  [sender velocityInView:self];
  switch (sender.state)
  {
    case UIGestureRecognizerStateBegan:
        [self stopDeceleratingTimer];
        seekerViewLeadingConstraintConstant = seekerViewLeadingConstraint.constant;
      break;
    case UIGestureRecognizerStateChanged:
      {
        double leading = seekerViewLeadingConstraintConstant + translation.x / 5.0;
        [self set:leading / self.bounds.size.width];
      }
      break;
    case UIGestureRecognizerStateEnded:
    case UIGestureRecognizerStateCancelled:
      {
        seekerViewLeadingConstraintConstant = seekerViewLeadingConstraint.constant;
        int direction = velocity.x > 0 ? 1 : -1;
        deceleratingVelocity = fabs(velocity.x) > decelerationMaxVelocity ? decelerationMaxVelocity * direction : velocity.x;
        self->deceleratingTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(handleDeceleratingTimer:) userInfo:nil repeats:YES];
      }
      break;
    default:
      break;
  }
}

- (void)set:(double)percentage
{
  self->value = distance * (double)(percentage > 1 ? 1 : (percentage < 0 ? 0 : percentage)) + min;
  CLog::Log(LOGDEBUG, "Slider::set percentage(%f), value(%f)", percentage, self->value);
}

- (void)updateViews
{
  if (distance == 0.0)
    return;
  seekerViewLeadingConstraint.constant = self.bounds.size.width * (CGFloat)((value - min) / distance);
  // seekerLabel.text = [delegate slider:self textWithValue:value];
  //seekerLabel.text = delegate?.slider(self, textWithValue: value) ?? "\(Int(value))"
}

//--------------------------------------------------------------
- (void)handleDeceleratingTimer:(id)obj
{
  double leading = seekerViewLeadingConstraintConstant + deceleratingVelocity * 0.01;
  [self set:(double)leading / self.bounds.size.width];
  //seekerViewLeadingConstraintConstant = seekerViewLeadingConstraint.constant

  deceleratingVelocity *= decelerationRate;
  if (![self isFocused] || fabs(deceleratingVelocity) < 1.0)
    [self stopDeceleratingTimer];
}

- (void)stopDeceleratingTimer
{
  [self->deceleratingTimer invalidate];
  self->deceleratingTimer = nil;
  self->deceleratingVelocity = 0.0;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
  CLog::Log(LOGDEBUG, "Slider::gestureRecognizerShouldBegin");
  if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
  {
    UIPanGestureRecognizer *panGestureRecognizer = (UIPanGestureRecognizer*)gestureRecognizer;
    CGPoint translation = [panGestureRecognizer translationInView:self];
    if (fabs(translation.x) > fabs(translation.y))
      return [self isFocused];
  }
  return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
  return YES;
}

@end
  
