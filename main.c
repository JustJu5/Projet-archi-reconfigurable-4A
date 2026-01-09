#include "mcc_generated_files/system.h"
#include "mcc_generated_files/pin_manager.h"
#include "mcc_generated_files/tmr1.h"   // gravité
#include "mcc_generated_files/tmr2.h"   // tick 20 ms

#include "lcd.h"

#include <xc.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdbool.h>

#define FCY 16000000UL
#include <libpic30.h>

/
static const uint8_t charEmpty[8]   = {0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};
static const uint8_t charFull[8]    = {0x1F,0x1F,0x1F,0x1F,0x1F,0x1F,0x1F,0x1F};
static const uint8_t charHalfTop[8] = {0b00110,0b00110,0b00110,0b00110,0,0,0,0};
static const uint8_t charHalfBot[8] = {0,0,0,0,0b11111,0b11111,0b11111,0b11111};


// IDs CGRAM
#define TILE_EMPTY_ID   0
#define TILE_FULL_ID    1
#define TILE_HALF_TOP   2
#define TILE_HALF_BOT   3


#define PIX_W 80
#define PIX_H 16
static uint8_t field[PIX_H][PIX_W];

static uint8_t board[PIX_H][PIX_W];


static const uint8_t pieces[5][4][4] = {
    // I
    { {1,1,1,1},{0,0,0,0},{0,0,0,0},{0,0,0,0} },
    // O
    { {1,1,0,0},{1,1,0,0},{0,0,0,0},{0,0,0,0} },
    // T
    { {1,1,1,0},{0,1,0,0},{0,0,0,0},{0,0,0,0} },
    // Z
    { {1,1,0,0},{0,1,1,0},{0,0,0,0},{0,0,0,0} },
    // L
    { {0,0,1,0},{1,1,1,0},{0,0,0,0},{0,0,0,0} }
};


static int px = 6, py = 0;
static int currentPiece = 0;


static volatile uint8_t tick20ms = 0;
static volatile uint8_t gravityFlag = 0;


#define BTN_LEFT_PRESSED   (PORTDbits.RD6 == 0)   // Gauche (S3)
#define BTN_RIGHT_PRESSED  (PORTDbits.RD7 == 0)   // Droite (S6)
#define BTN_DOWN_PRESSED   (PORTDbits.RD13 == 0)  // Bas (S4)


static void clearField(void)
{
    for (int y = 0; y < PIX_H; y++)
        for (int x = 0; x < PIX_W; x++)
            field[y][x] = board[y][x]; // 0 = vide
    
    for (int y = 0; y < 4; y++)
        for (int x = 0; x < 4; x++)
            if (pieces[currentPiece][y][x])
                field[py + y][px + x] = 1;
}



static void lockPiece(void){
    for (int y = 0; y < 4; y++)
        for (int x = 0; x < 4; x++)
            if (pieces[currentPiece][y][x])
                board[py + y][px + x] = 1;
}
static void newPiece(void)
{
    currentPiece = rand() % 5;
    px = 6;
    py = 0;
}

static int collision(int nx, int ny)
{
    for (int y = 0; y < 4; y++) {
        for (int x = 0; x < 4; x++) {
            if (pieces[currentPiece][y][x]) {
                int fx = nx + x;
                int fy = ny + y;
                if (fx < 0 || fx >= PIX_W)  return 1;
                if (fy < 0 || fy >= PIX_H)  return 1;
                if (board[fy][fx])          return 1; // 1 = occupé
            }
        }
    }
    return 0;
}

static void drawPiece(void)
{
    for (int y = 0; y < 4; y++)
        for (int x = 0; x < 4; x++)
            if (pieces[currentPiece][y][x])
                field[py + y][px + x] = 1;
}



static void drawLCD(void)
{
    LDC_Cursor(0,0);
    for(int col=0; col<16; col++)
    {
        uint8_t top=0, bot=0;
        for(int y=0; y<8; y++)   top |= field[y][col];
        
 
        if(top && bot)      LCD_PutChar(1); // full
        else if(top)       LCD_PutChar(2); // half top
        else if(bot)       LCD_PutChar(3); // half bot
        else               LCD_PutChar(0); // empty
    }
 
    LDC_Cursor(0,1);
    for(int col=0; col<16; col++)
    {
        uint8_t top=0, bot=0;
        
        for(int y=8; y<16; y++)  bot |= field[y][col];
 
        if(top && bot)      LCD_PutChar(1);
        else if(top)       LCD_PutChar(2);
        else if(bot)       LCD_PutChar(3);
        else               LCD_PutChar(0);
    }
}

static void TMR1_ISR(void)   // gravité (~800 ms)
{
    gravityFlag = 1;
}

static void TMR2_ISR(void)   // tick 20 ms
{
    tick20ms = 1;
}

static int isfull(int y){
    for(int x=0; x<PIX_W; x++){
        if(board[y][x] == 0)
            return 0;
    }
    return 1;
    
}

static void suppline(int y){
    for(int yy = y; yy > 0; yy--){
        for(int x=0; x< PIX_W; x++){
            board[yy][x] = board[yy-1][x];
        }
    }
    for(int x=0; x<PIX_W; x++)
        board[0][x] = 0;
}

static void checkline(void)
{
    for(int y =0; y<PIX_H; y++){
        if(isfull(y)){
            suppline(y);
            y--;
        }
    }
}


int main(void)
{
    SYSTEM_Initialize();
    for (int y = 0; y<PIX_H; y++)
                for (int x=0; x<PIX_W; x++)
                    board[y][x] = 0;
    LCD_Initialize();

    // Charger les 4 glyphes CGRAM
    LCD_CreateChar(TILE_EMPTY_ID, charEmpty);
    LCD_CreateChar(TILE_FULL_ID,  charFull);
    LCD_CreateChar(TILE_HALF_TOP, charHalfTop);
    LCD_CreateChar(TILE_HALF_BOT, charHalfBot);

    // Attacher les callbacks Timer
    TMR1_SetInterruptHandler(TMR1_ISR);   // gravité : configure TMR1 dans MCC (~800 ms, interrupt ON)
    TMR2_SetInterruptHandler(TMR2_ISR);   // tick :   configure TMR2 dans MCC (~20 ms, interrupt ON)

    // Démarrer les timers si MCC ne start pas automatiquement
    TMR1_Start();
    TMR2_Start();

    // Grille et première pièce
    clearField();
    newPiece();

    // Auto-repeat simple (évite trop de répétitions)
    uint8_t repLeft  = 0;
    uint8_t repRight = 0;
    uint8_t repDown  = 0;

    while (1)
    {
        // Tick de rendu/inputs
        if (tick20ms)
        {
            tick20ms = 0;

            // ---- Entrées (polling + repeat) ----
            if (BTN_LEFT_PRESSED)  { if (++repLeft  > 2) { repLeft  = 0; if (!collision(px-1, py)) px--; } }
            else repLeft  = 2;

            if (BTN_RIGHT_PRESSED) { if (++repRight > 2) { repRight = 0; if (!collision(px+1, py)) px++; } }
            else repRight = 2;

            if (BTN_DOWN_PRESSED)  { if (++repDown  > 1) { repDown  = 0; if (!collision(px,   py+1)) py++; } }
            else repDown  = 1;

            clearField();
            
            drawPiece();
            drawLCD();
        }

        // Gravité
        if (gravityFlag)
        {
            gravityFlag = 0;
            if (!collision(px, py+1)) 
            {
                py++;
            }
            else 
            {
                lockPiece();
                checkline();
                newPiece();
            }                     
        }
    }
    return 0;
}
