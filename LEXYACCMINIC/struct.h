#ifndef __STRUCT_H__
#define __STRUTCT_H__

#define TOKEN_LIST_MAX 100 
#define TOKEN_VALUE_MAX 10
#define SYMBOL_TABLE_MAX 100
#define SYMBOL_MAX 10

			/************************************************************************
		 *																	    *
		 * 토큰들을 선언한 enum												     	*
		 *																	    *
		 * ID - 변수(Identifier)에 대한 토큰									        *
		 * INT - 정수 상수에 대한 토큰											        *
		 * REAL - 정수 실수에 대한 토큰											    *
		 * PLUS - 덧셈 연산자에 대한 토큰										        *
		 * MINUS - 뺄셈 연산자에 대한 토큰										        *
		 * MUL - 곱셈 연산자에 대한 토큰										        *
		 * DIV - 나눗셈 연산자에 대한 토큰										        *
		 * ASSIGN - Assignment 연산자에 대한 토큰								        *
		 * LP - 왼 괄호 특수 문자에 대한 토큰									            *
		 * RP - 오른 괄호 특수 문자에 대한 토큰
		 * LT - <
		 * LE - <=
		 * GT - >
		 * GE - >=
		 * EE - ==
		 * NE - !=
		 ***********************************************************************/
		typedef enum { T_ID = 1, T_INT, T_REAL, T_PLUS, T_MINUS, T_MUL, T_DIV, T_ASSIGN, T_LP, T_RP, T_GT, T_GE, T_LT, T_LE, T_EE, T_NE, T_IF, T_ELSE, T_WHILE, T_PRINT} TOKEN;

		struct TL{
			TOKEN token;
			char value[TOKEN_LIST_MAX+1];
		};

		/************************************************************************
		 *																	    *
		 * 심볼테이블을 위한 구조체												        * 
		 * 심볼테이블은 배열로 구성한다.										            *
		 *																	    *
		 * 심볼테이블은 다음과 같이 구성된다.									            *
		 * symbol(@char[10]) - 입력한 수식에서 변수(Identifier)가 저장된다.		        *
		 * (symbol은 최대 10자를 넘지 않는다고 가정한다.)						            *
		 * type(@TOKEN) - 변수에 저장되는 값이 정수인지 실수인지				                *
		 *				  구분하기 위한 타입 정보입니다. 						            *
		 * value(@union) - 변수에 저장되는 값을 나타냅니다.						        *
		 ***********************************************************************/
		struct ST{
			char symbol[SYMBOL_MAX+1];
			TOKEN type;
			union {
				int integer_constant;
				double real_constant;
			} value;
		};

			/*************************************************************************
		*Syntax Tree를 위한 구조체
		*************************************************************************/

typedef struct TL TOKEN_LIST;
typedef struct ST SYMBOL_TABLE;
typedef struct TL* ptr_TOKEN_LIST;

#endif
