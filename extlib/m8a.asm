; M8A(MASDX 8COLOR TYPE-A) GRAPHIC LOADER by hex125(293)

include "LDXEQU.ASM"

	ORG	$0100

	JP	START		; �v���O�����J�n

ERR:
	LD	DE, ERRMES01	; ���s���͏I��
ERR2:
	LD	C, _STROUT	; �\��
	JP	SYSTEM

FILECLOSE:
	LD	DE, FCB1
	LD	C, _FCLOSE
	JP	SYSTEM

START:
	LD	DE, TITLE	; �^�C�g���\��
	LD	C, _STROUT
	CALL	SYSTEM

	LD	A, (DTA1)	; �������邩�H
	OR	A
	JR	NZ, START2

	LD	DE, USAGE	; �����Ȃ���Ύg�p���@�\��
	JR	ERR2

START2:
	LD	DE, FCB1	; �t�@�C���I�[�v��
	LD	C, _FOPEN
	CALL	SYSTEM
	OR	A		
	JP	Z, READ

	CALL	FILECLOSE
	JR	ERR

READ:
	LD	HL, 1		; ���R�[�h�T�C�Y��1�ɂ���
	LD	(FCB1+14), HL

	DEC	HL		; �����_�����R�[�h������
	LD	(FCB1+33), HL
	LD	(FCB1+35), HL

	LD	DE, BUFAD	; �ǂݏo����
	LD	C, _SETDTA	; DTA�̐ݒ�
	CALL	SYSTEM

READLOOP01:
	LD	DE, FCB1
	LD	HL, (FCB1+16)	; �ǂݏo���T�C�Y

	PUSH	HL
	LD	HL, ($0006)	; �t���[�G���A���`�F�b�N
	LD	DE, BUFAD
	OR	A
	SBC	HL, DE
	LD	D, H
	LD	E, L
	POP	HL

SIZECHK:
	PUSH	HL		; CP HL, DE
	OR	A
	SBC	HL, DE
	POP	HL

	JR	C, READSTART

ERR3:
	CALL	FILECLOSE	; Too large file.
	LD	DE, ERRMES02	; �I��
	JP	ERR2
	

READSTART:
	LD	DE, FCB1
	LD	C, _RDBLK
	CALL	SYSTEM

	CP	$ff
	JR	Z, READEXIT02

	PUSH	AF
	LD	DE, BUFAD

READLOOP02:
	LD	A, H
	OR	L
	JR	Z, READEXIT01

	LD	A, (DE)
	INC	DE

	DEC	HL
	JR	READLOOP02

READEXIT01:
	POP	AF
	OR	A
	JR	Z, READLOOP01

READEXIT02:
	CALL	FILECLOSE	; �t�@�C���N���[�Y

PALETON:
	LD	BC, $10AA
	OUT	(C), C
	LD	BC, $11CC
	OUT	(C), C
	LD	BC, $12F0
	OUT	(C), C
	INC	B
	DB	$ED, $71	; OUT (C),0

SET_CRTC:
;	LD	A, (REWRITE00+1)
;	JP	DRAW_BG		; �`��



;------------------------------------------------------------------------------
#LIB M8ALOAD
DRAW_BG:
;�w�i�摜��`�悷��(320x200�Œ�)
; input: HL=�f�[�^�J�n�ʒu
;        L =�\���J�n�ʒu�i�c�j
;
; DB nnGRBGRB
;    | |  |
;    | |  dot1
;    | dot2
;    n=0 : next byte is repeat length
;    n!=0: repeat length (1�`3)

; HL .... DATA POINTER
; B ..... WIDTH COUNTER(DEC)
; C ..... HEIGHT COUNTER(DEC)

; BC' ... VRAM address
; D' .... BLUE
; E' .... RED
; H' .... GREEN
; L' .... TEMP.

; IXH ... color code
; IXL ... rep counter	

;------------------------------------------------------------------------------
;;;;	LD	HL, BUFAD

PALETON:
	LD	BC, $10AA
	OUT	(C), C
	LD	BC, $11CC
	OUT	(C), C
	LD	BC, $12F0
	OUT	(C), C
	INC	B
	DB	$ED, $71	; OUT (C),0

	LD	A,0
	LD	BC,$1FD0
	OUT	(C),A

	LD	A, (HL)		; ���i�������J��Ԃ����j
	INC	HL
	LD	(REWRITE00+1), A


	CP	41
	JR	NC, WIDTH80
WIDTH40:
	LD	A, 40
	JR	WIDTH
WIDTH80:
	LD	A, 80
WIDTH:
	LD	(REWRITE02+1), A


	LD	A, (HL)		; �����i�c�����J��Ԃ����j
	INC	HL
	LD	(REWRITE01+1), A

;------------------------------------------------------------------------------
	CALL	SET_BGDAT			;	�擾
	LD	B, 0				;	�c��Y��
;------------------------------------------------------------------------------
DRAW_BG00:
	LD	A, B				;	A=�c���W
REWRITE00:
	LD	C, $00				;	C=����X��

	EXX
		; ���[���W�̌v�Z
		;(Y AND 7)*2^11 + (Y \ 8)*B3	
		LD	C, A
		AND	7
		ADD	A, A
		ADD	A, A
		ADD	A, A
		LD	IYL, A

		LD	A, C
;		SRL	A		;
;		SRL	A		;
;		SRL	A		;24
		RRCA			;
		RRCA			;
		RRCA			;12
		AND	00011111B	;19


		LD	B, A
REWRITE02:
		LD	A, 0

	; A�~B = HL
AXBHL:
	LD	HL, 0			; 21 00 00	���ʂ��N���A
	LD	D, H			; 54		
	LD	E, B			; 58		DE=B
	LD	B, 8			; 06 08		8bit�Ԃ�J��Ԃ�(counter)
AXBHL00:
	RRCA				; 0f		�ŉ���bit��Cy�ɓ���
	JR	NC, AXBHL01		; 30 01		
	ADD	HL, DE			; 19		Cy=1�Ȃ�DE��������
AXBHL01:
	SLA	E			; cb 23
	RL	D			; cb 12		DE���V�t�g
	DJNZ	AXBHL00			; 10 f6


	; H+A
	LD	A, IYL
	ADD	A, H
	LD	B, A
	LD	C, L
	SET	6, B
	EXX

;------------------------------------------------------------------------------
DRAW_BG01:
	EXX
		LD	A, IXH		; A=�F�R�[�h

BITSET07:
		RRA				; 1f		4	blue
		RL	D			; cb 12		8/12
		RRA				; 1f		4/16	red
		RL	E			; cb 13		8/24
		RRA				; 1f		4/28	green
		RL	H			; cb 12		8/40
BITSET06:
		RRA				; 1f		4/48	blue
		RL	D			; cb 12		8/56
		RRA				; 1f		4/60	red
		RL	E			; cb 13		8/68
		RRA				; 1f		4/72	green
		RL	H			; cb 12		8/84

		DEC	IXL			; dd 2d		8
		CALL	Z, SET_BGDAT2		; cc xx xx		�J�E���^��0�ɂȂ�����ēx�f�[�^���擾

		LD	A, IXH			; dd 7c		8	A=color code(HI)

BITSET05:
		RRA				; 1f		4	blue
		RL	D			; cb 12		8/12
		RRA				; 1f		4/16	red
		RL	E			; cb 13		8/24
		RRA				; 1f		4/28	green
		RL	H			; cb 12		8/40
BITSET04:
		RRA				; 1f		4/48	blue
		RL	D			; cb 12		8/56
		RRA				; 1f		4/60	red
		RL	E			; cb 13		8/68
		RRA				; 1f		4/72	green
		RL	H			; cb 12		8/84

		DEC	IXL			; dd 2d		8
		CALL	Z, SET_BGDAT2		; cc xx xx		�J�E���^��0�ɂȂ�����ēx�f�[�^���擾

		LD	A, IXH			; dd 7c		8	A=color code(HI)

BITSET03:
		RRA				; 1f		4	blue
		RL	D			; cb 12		8/12
		RRA				; 1f		4/16	red
		RL	E			; cb 13		8/24
		RRA				; 1f		4/28	green
		RL	H			; cb 12		8/40
BITSET02:
		RRA				; 1f		4/48	blue
		RL	D			; cb 12		8/56
		RRA				; 1f		4/60	red
		RL	E			; cb 13		8/68
		RRA				; 1f		4/72	green
		RL	H			; cb 12		8/84

		DEC	IXL			; dd 2d		8
		CALL	Z, SET_BGDAT2		; cc xx xx		�J�E���^��0�ɂȂ�����ēx�f�[�^���擾

		LD	A, IXH			; dd 7c		8	A=color code(HI)

BITSET01:
		RRA				; 1f		4	blue
		RL	D			; cb 12		8/12
		RRA				; 1f		4/16	red
		RL	E			; cb 13		8/24
		RRA				; 1f		4/28	green
		RL	H			; cb 12		8/40
BITSET00:
		RRA				; 1f		4/48	blue
		RL	D			; cb 12		8/56
		RRA				; 1f		4/60	red
		RL	E			; cb 13		8/68
		RRA				; 1f		4/72	green
		RL	H			; cb 12		8/84

		DEC	IXL			; dd 2d		8
		CALL	Z, SET_BGDAT2		; cc xx xx		�J�E���^��0�ɂȂ�����ēx�f�[�^���擾
;		LD	A, IXH			; dd 7c		8	A=color code(HI)

;------------------------------------------------------------------------------
; GVRAM�ɓ]��
TRANS2GVRAM:
		LD	L, B

		OUT	(C), D			; ed 51		12/23	BLUE out

		LD	A, $40			; 3e 40		 7/30	B->R��
		ADD	A, B			; 80		 4/34
		LD	B, A			; 47		 4/38
		OUT	(C), E			; ed 59		12/50	RED out

		SET	6, B			;			R->G��
		OUT	(C), H			; ed 79		12/	GREEN out

		LD	B, L

;------------------------------------------------------------------------------
		; �\���ʒu����������--
		INC	BC

	EXX

	DEC	C				; ������
	JR	NZ, DRAW_BG01

;------------------------------------------------------------------------------
	;�\���ʒu���c������--
	INC	B
REWRITE01:
	LD	A, 200				; �c��Y��
	CP	B
	JP	NZ, DRAW_BG00
	RET

;------------------------------------------------------------------------------
; ���k�f�[�^����ݒ���擾(��)
SET_BGDAT2:
	EXX			;�\��
	CALL	SET_BGDAT
	EXX
	RET
;------------------------------------------------------------------------------
; ���k�f�[�^����ݒ���擾
;in:  HL =read address
;out: IXH=color code
;     IXL=rep counter
SET_BGDAT:
	LD	A, (HL)			; �F�R�[�h���擾
	INC	HL
	LD	IXH, A			; �F�R�[�h��ݒ�

	AND	11000000B
	JR	Z, SET_BGDAT02		; ���2bit��0�̏ꍇ�́A���̃o�C�g���J��Ԃ���-1

	; ���2bit��00�łȂ��ꍇ
	LD	A,IXH			; �F�R�[�h�����ǂ��i�J��Ԃ������擾�j
	RLCA
	RLCA
	AND	00000011B		; A=�J��Ԃ���
	JR	SET_BGDAT03

SET_BGDAT02:				; ���2bit��00�̏ꍇ
	LD	A, (HL)			; �J��Ԃ��񐔂��擾
	INC	HL
	INC	A			; +1����
SET_BGDAT03:
	LD	IXL, A			; �J��Ԃ��񐔂�ݒ�

	RET


;------------------------------------------------------------------------------
TITLE:
	DB	"M8A Graphic Loader v0.01 by hex125(293)",$0a,$0d,"$"
USAGE:
	DB	"Usage: M8A ̧��Ȱ�$"
ERRMES01:
	DB	"File not found.$"
ERRMES02:
	DB	"Too large file. Cannot show.$"

BUFAD:

#ENDLIB

