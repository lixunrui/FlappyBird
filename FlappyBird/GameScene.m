//
//  GameScene.m
//  FlappyBird
//
//  Created by Raymond Li on 15/4/11.
//  Copyright (c) 2015年 Raymond Li. All rights reserved.
//

#import "GameScene.h"

@interface GameScene()


@end

static const NSInteger BirdZPosition = 100;
static const NSInteger PipeZPosition = 100;
static const NSInteger LabelZPosition = 99;
static const NSInteger MessageZPosition = 101;

static const NSInteger PipeDistence = 200;

static const uint32_t BirdCategory = 0x01;
static const uint32_t PipeCategory = 0x01<<1;
static const uint32_t scoreCategory = 0x01<<2;

@implementation GameScene
{
    SKSpriteNode* bird;
    SKLabelNode* messageLabel;
    bool gameStart;
    CGSize viewSize;
    int PipeMoveSpeed;
    NSTimeInterval populatePipe;
    bool showMessageLabel;
    int passedPipeNumber;
    bool gameOver;
    int pipeGenerateGap;
}

#pragma mark - Init 
- (instancetype)initWithSize:(CGSize)size
{
    // init background
    if (self = [super initWithSize:size]) {
        SKTexture* backgroundImage = [SKTexture textureWithImage:[UIImage imageNamed:@"background.png"]];
        
        SKSpriteNode* background = [SKSpriteNode spriteNodeWithTexture:backgroundImage];
        
        background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        
        background.size = CGSizeMake(self.size.width, self.size.height);
        
        [self addChild:background];
        
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsWorld.gravity = CGVectorMake(0, -5);
    
        self.physicsWorld.contactDelegate = self;
        
        viewSize = size;
        
        [self CreateBackGround];
        // set the view size
        
        
        // init values
        gameStart = NO;
        PipeMoveSpeed = 6;
        showMessageLabel = NO;
        passedPipeNumber = 0;
        gameOver=NO;
        pipeGenerateGap = 2.1;
    }
    return self;
}

#pragma mark - background change
-(void) CreateBackGround
{
    SKTexture* background = [SKTexture textureWithImageNamed:@"background"];
    background.filteringMode = SKTextureFilteringNearest;
    
    SKAction* moveGround = [SKAction moveByX:-background.size.width y:0 duration:0.002* background.size.width*2];
    SKAction* moveDown = [SKAction moveByX:0 y:-background.size.height duration:0.01];
    SKAction* resetGround = [SKAction moveByX:background.size.width y:0 duration:0.002* background.size.width*2];
    SKAction* moveUp = [SKAction moveByX:0 y:background.size.height duration:0.01];
    SKAction* backgroundMove = [SKAction repeatActionForever:[SKAction sequence:@[moveGround,moveDown, resetGround, moveUp]]];
    //SKAction* move2 = [SKAction repeatActionForever:moveGround];
    
    NSLog(@"value is %f", background.size.width);
    for (int i = 0; i<2; i++) {NSLog(@"i= %i",i);
        SKSpriteNode* sprite = [SKSpriteNode spriteNodeWithTexture:background];
        [sprite setScale:1];
        sprite.position = CGPointMake(i* background.size.width, background.size.height/2);
        [sprite runAction:backgroundMove];
        [self addChild:sprite];
    }
}

#pragma mark - Move To View
-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    
    SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    
    myLabel.text = @" Flappy Bird";
    myLabel.name = @"mylabel";
    myLabel.fontSize = 25;
    myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                   CGRectGetMidY(self.frame));
    
    [self addChild:myLabel];
    
    [self AddBird];
}

#pragma mark - Add Bird
-(void) AddBird
{
    bird = [SKSpriteNode spriteNodeWithImageNamed:@"bird"];
    bird.name=@"bird";
    //resize the bird image
    bird.xScale = 0.2;
    bird.yScale = 0.2;
    
    bird.position = CGPointMake(viewSize.width/3, viewSize.height/2);
    
    // add physicBody
    bird.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:bird.size.height/2];
    bird.physicsBody.allowsRotation = NO;
    
    bird.physicsBody.categoryBitMask = BirdCategory;
    bird.physicsBody.contactTestBitMask = PipeCategory | scoreCategory;
    
    //set Zposition
    bird.zPosition = BirdZPosition;
    
    bird.physicsBody.dynamic = NO;
    
    [self addChild:bird];
}

#pragma mark - Add pipes after click
-(void) AddPipeAndScore
{
    SKTexture* pipeTexture = [SKTexture textureWithImageNamed:@"pipe"];
    pipeTexture.filteringMode = SKTextureFilteringNearest;
    
    
//    SKNode* pipePair = [SKNode node];
//    pipePair.position = CGPointMake(viewSize.width + pipeTexture.size.width, 0);
//    pipePair.zPosition = PipeZPosition;
    
    // set the pipe length
    int minY = 0;
    int maxY = viewSize.height - PipeDistence;
    int actualY = ((arc4random() % (maxY - minY)) + minY);
    
    // add bottom pipe
    SKSpriteNode* pipe1 = [SKSpriteNode spriteNodeWithTexture:pipeTexture];
    //pipe1.name = @"pipe";
    //NSLog(@"Width %f, Heigh %f", pipe.size.width, pipe.size.height);
    //pipe.centerRect = CGRectMake(10/165, 252/305, 140/165, 50/305);
    
    pipe1.size = CGSizeMake(pipe1.size.width/2, actualY);
    pipe1.name=@"pipe";
    
    pipe1.position = CGPointMake(viewSize.width + pipe1.size.width/2, pipe1.size.height/2);
    
    pipe1.zPosition = PipeZPosition;
    
    pipe1.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipe1.frame.size];
    
    pipe1.physicsBody.categoryBitMask = PipeCategory;
    
    pipe1.physicsBody.dynamic = NO;
    
    SKAction* move = [SKAction moveToX:-(viewSize.width+ pipe1.size.width) duration:PipeMoveSpeed];
    SKAction* remove = [SKAction removeFromParent];
    
    SKAction* PipeMove = [SKAction sequence:@[move, remove]];
    
    [pipe1 runAction:PipeMove withKey:@"movepipe"];
    
    [self addChild:pipe1];
    
    // add top pipe
    
    SKSpriteNode* pipe2 = [SKSpriteNode spriteNodeWithTexture:pipeTexture];
   // pipe2.name = @"pipe";
    
    pipe2.size = CGSizeMake(pipe2.size.width/2, viewSize.height-pipe1.size.height-PipeDistence);
    
    pipe2.name = @"pipe";
    
    pipe2.zRotation = ((180*M_PI)/180);
    
    pipe2.zPosition = PipeZPosition;
    
    pipe2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipe2.frame.size];
    
    pipe2.physicsBody.categoryBitMask = PipeCategory;
    
    pipe2.physicsBody.dynamic = NO;
    
    pipe2.position = CGPointMake(viewSize.width + pipe1.size.width/2, viewSize.height - pipe2.size.height/2);
    
    [pipe2 runAction:PipeMove withKey:@"movepipe"];
    
    [self addChild:pipe2];
    
    // add score
    SKNode* score = [SKNode node];
    score.position = CGPointMake(viewSize.width + pipe1.size.width, pipe1.size.height+ PipeDistence/2);
    
    score.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(1, viewSize.height)];
    
    score.physicsBody.categoryBitMask = scoreCategory;
    score.zPosition = PipeZPosition;
    
    score.physicsBody.dynamic = NO;
    [score runAction:PipeMove withKey:@"movepipe"];
    
    [self addChild:score];
}

#pragma mark - Add Actions
-(void) BirdClicked
{
    CGVector vector = CGVectorMake(0, 35);
    [bird.physicsBody applyImpulse:vector];
}

#pragma mark - Touch Events
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//    UITouch* touch = [touches anyObject];
//    CGPoint location = [touch locationInNode:self];
//    SKNode* node = [self nodeAtPoint:location];
    
    if( gameOver == NO)
    {
        bird.physicsBody.dynamic=YES;
        [self BirdClicked];
        gameStart=YES;
    
        if (showMessageLabel == NO) {
            [self ShowMessageLabel];
            showMessageLabel = YES;
        }
    }
    
    UITouch* touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode* node = [self nodeAtPoint:location];
    
    if ([[node name]isEqualToString:@"over"]) {
        GameScene * newGame = [GameScene sceneWithSize:viewSize];
        [self.view presentScene:newGame];
    }

}


#pragma mark - Generate Pipes based on time
- (CGFloat) clamp: (CGFloat) value
{
    if (value > 0.5) {
        return 0.5;
    } else if (value < -1)
        return -1;
    return value;
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    bird.zRotation = [self clamp:bird.physicsBody.velocity.dy];
    NSTimeInterval timePeriod = currentTime - populatePipe;
    //populatePipe =  currentTime;
    
    if (timePeriod > pipeGenerateGap && gameOver == NO && gameStart == YES) {
        [self AddPipeAndScore];
        populatePipe = currentTime;
    }
}

#pragma mark - Contact degelation
-(void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody* contactBody;
    
    if (contact.bodyA.categoryBitMask > contact.bodyB.categoryBitMask) {
        contactBody = contact.bodyA;
    }
    else
        contactBody =  contact.bodyB;
    
    // simler body should be the bird
    if (contactBody.categoryBitMask == PipeCategory) {
        [self ShowResults];
        gameOver = YES;
        [self removeActionForKey:@"flash"];
        [self runAction:[SKAction sequence:@[[SKAction repeatAction:[SKAction sequence:@[[SKAction runBlock:^{self.backgroundColor = [SKColor redColor];}],[SKAction waitForDuration:0.05],[SKAction runBlock:^{self.backgroundColor = [SKColor whiteColor];}],[SKAction waitForDuration:0.05]]] count:4]
                                             ]]withKey:@"flash"];
    }
    
    if (contactBody.categoryBitMask == scoreCategory) {
        [contactBody.node removeFromParent];
        passedPipeNumber++;

        messageLabel.text = [NSString stringWithFormat:@"%i", passedPipeNumber];
    }
}

#pragma mark - Show End Label or message label
-(void) ShowResults
{
    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Futura Medium"];
    label.text = @"GAME OVER";
    label.name=@"over";
    label.fontColor = [SKColor blackColor];
    label.fontSize = 44;
    label.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
    label.zPosition = MessageZPosition;
    [self addChild:label];
    
    NSArray* pipes = [[self scene]objectForKeyedSubscript:@"pipe"];
    for (SKNode* node in pipes) {
        [node removeActionForKey:@"movepipe"];
    }
}

-(void) ShowMessageLabel
{
    messageLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura Medium"];
    
    messageLabel.text = [NSString stringWithFormat:@"%i", passedPipeNumber];
    
    messageLabel.fontSize = 20;
    
    messageLabel.fontColor = [SKColor grayColor];
    
    messageLabel.position = CGPointMake(viewSize.width/2, (viewSize.height/3)*2);
    
    messageLabel.zPosition = MessageZPosition;
    
    [self addChild:messageLabel];
}


@end
