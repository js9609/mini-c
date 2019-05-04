%{
	#include <stdio.h>
	#include <string.h>
	#include <stdbool.h>

	/************************************************************************************
	 *																				    *
	 * 매크로 선언																		    *
	 *																				    *
	 * TOKEN_LIST_MAX - 배열로 구현되는 토큰 리스트의 사이즈.							            *	
	 * 샘플로 제공되는 해당 어휘분석기에서 토큰 리스트 배열에 저장되는 아이템은			                        *
	 * 최대 100개를 넘지 않는다고 가정한다.												        *
	 *																					*
	 * TOKEN_VALUE_MAX - 토큰 리스트의 아이템 중 value 문자열 사이즈					                *
	 * 샘플로 제공되는 해당 어휘분석기에서 각 토큰에 해당하는 값은					                     	*
	 * 최대 10자를 넘지 않는다고 가정한다.												            *
	 *																					*
	 * SYMBOL_TABLE_MAX - 배열로 구현되는 심볼테이블의 사이즈.							            *	
	 * 해당 샘플로 제공되는 어휘분석기에서 심볼 테이블 배열에 저장되는 아이템은			                        *
	 * 최대 100개를 넘지 않는다고 가정한다.											         	*
	 *																					*
	 * SYMBOL_MAX - 심볼 테이블에 저장되는 심볼 문자열 사이즈							                *
	 * 샘플로 제공되는 해당 어휘분석기에서 심볼은 최대 10자를 넘지 않는다고 가정한다.	                            *
	 * (주의) 2차 과제에서 주어진 조건과 다릅니다!!.									                *
     *        위에서의 가정은 샘플로 제공되는 어휘 분석기의 구현을 간단하게 하기		                        *
	 *        위한 것입니다.															        *
	 *																					*
	 ************************************************************************************/
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
	 * RP - 오른 괄호 특수 문자에 대한 토큰									        *
	 *																	    *
	 * (주의) 반드시 이걸 사용해서 구현 안하셔도 됩니다 !!. 				                *
	 * (주의) 본인이 편한 방식으로 구현 하셔도 됩니다 !!.					                *
	 *																	    *
	 ***********************************************************************/
	typedef enum { ID = 1, INT, REAL, PLUS, MINUS, MUL, DIV, ASSIGN, LP, RP } TOKEN; 

	/***********************************************************************
	* Syntax Tree를 위해 선언한 ENUM
	* Binary - +,-,*,/,=
	* Unary - \-
	* CONTANT - INT, REAL
	***********************************************************************/


	/************************************************************************
	 *																	    *
	 * 토큰 리스트를 위한 구조체											            *
	 * 토큰 리스트는 배열로 구성한다.										            *
	 *																	    *
	 * 토큰 리스트는 다음과 같이 구성된다.									            *
	 * token(@TOKEN) - lexical analyzer에서 사용하는 토큰					        *
	 * value(@char[10]) - 토큰에 해당하는  값 (Lexeme이 아닙니다.)			            *
	 * (value는 최대 10자를 넘지 않는다고 가정한다.)						            *
	 *																		*
	 * ex1) > var = 10														*
	 *																		*
	 *	   TOKEN		VALUE												*
	 *																		*
	 *	    ID			 var												*
	 *	    ASSIGN			 												*
	 *	    NUM		     10	 												*
	 *																		*
	 * ex2) > 10 + 5.23														*
	 *																		*
	 *	   TOKEN		VALUE												*
	 *																		*
	 *	    NUM			 10													*
	 *	    PLUS			 												*
	 *	    NUM		     5.23	 											*
	 *																		*
	 * (주의) 반드시 이걸 사용해서 구현 안하셔도 됩니다 !!. 				                *
	 * (주의) 본인이 편한 방식으로 구현 하셔도 됩니다 !!.					                *
	 *																	    *
	 ***********************************************************************/
	typedef struct {
		TOKEN token;
		char value[TOKEN_VALUE_MAX+1];
	}TOKEN_LIST;


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
	 *																	    *
	 * (주의) 반드시 이걸 사용해서 구현 안하셔도 됩니다 !!. 				                *
	 * (주의) 본인이 편한 방식으로 구현 하셔도 됩니다 !!.					                *
	 *																	    *
	 ***********************************************************************/
	typedef struct {
		char symbol[SYMBOL_MAX+1];
		TOKEN type;
		union {
			int integer_constant;
			double real_constant;
		} value;
	} SYMBOL_TABLE;

	/*************************************************************************
	*Syntax Tree를 위한 구조체







	*************************************************************************/
	typedef struct SN{
		char symbol[SYMBOL_MAX+1];
		TOKEN token;
		struct SN* Left;
		struct SN* Right;
	}SYNTAX_NODE;

	/* Variables */
	TOKEN_LIST token_list[TOKEN_LIST_MAX];			// 사이즈가 100인 토큰 리스트 배열
	SYMBOL_TABLE symbol_table[SYMBOL_TABLE_MAX];	// 사이즈가 100인 심볼 테이블 배열
	int token_number = 0;							// 토큰 리스트에 저장된 토큰의 수
	int symbol_number = 0;							// 심볼 테이블에 저장된 심볼의 수

	/* Functions */
	void do_lexical_analysis();
	void yyerror(char* );
	void initialize_symbol_table();
	bool is_symbol_duplicated(char* target);
	int find_symbol(char* target);
	void initialize_token_list(); 
	void print_token_list();
	void save_token(TOKEN token, char* value);
	void save_symbol(char* symbol);



	/* ADDED Variables */
	int next_token_idx;
	int lexical_error_occured;
	int syntax_error_occured;
	int variable_not_defined;
		
	/* PRODUCTION RULES (생성규칙 정의) -- 좌재귀제거 및 좌인수분해
		E->VariableAE' | ValueE' | -EE' | (E)
		A-> =E|e
		Variable -> ID
		Value -> INT | REAL
		E' -> +EE' | -EE' | *EE | /EE'
	*/
	/*ADDED FUNCTION*/
	void do_syntax_analysis();
	void symbol_not_exist(char *w);
	double calculate(SYNTAX_NODE* node);
	int match(int expected);
	void free_all(SYNTAX_NODE* node);
	void lexical_error();
	void syntax_error();
	
	void print_tree(SYNTAX_NODE* node);

	SYNTAX_NODE* makeNode(TOKEN tok, SYNTAX_NODE* left, SYNTAX_NODE* right);
	
	SYNTAX_NODE* A();
	SYNTAX_NODE* restA(SYNTAX_NODE* call);
	SYNTAX_NODE* E();
	SYNTAX_NODE* restE(SYNTAX_NODE* call);
	SYNTAX_NODE* T();
	SYNTAX_NODE* restT(SYNTAX_NODE *call);
	SYNTAX_NODE* F();
	SYNTAX_NODE* restF();

%}
	/*************************************************************************
	 *																		 *
	 * 변수(Identifier) 에 대한 정규 표현식									         *
	 *																		 *
	 *************************************************************************/
id [a-zA-Z_][a-zA-Z0-9_]*

	/**************************************************************************
	 *																		  *
	 * 정수 상수에 대한 정규 표현식											          *
	 *																		  *
	 **************************************************************************/
integer [1-9][0-9]*

	/**************************************************************************
	 *																		  *
	 * 실수 상수에 대한 정규 표현식											          *
	 *																		  *
	 **************************************************************************/
real (0|[1-9][0-9]*)\.(0|[0-9]*[1-9])

	/***************************************************************************
	 *																		   *
	 * 구획 문자(delimiter)에 대한 정규 표현식								           *
	 *																		   *
	 ***************************************************************************/
delim [ \t\r]
ws {delim}+

	/******************************************************************************
	 *																			  *
	 * 변수(Identifier)가 underscore만 이루어진 예외적인 경우를 처리하기 위한 	                  * 
	 * 정규 표현식																      *
	 *																			  *
	 ******************************************************************************/
under_score [_]+

	/**************************************************************************
	 *																		  *
	 * 변수(Identifier)의 첫 글자가 숫자로 시작하는 예외적인 경우를			                  *
	 * 처리하기 위한 정규 표현식											              * 
	 *																		  *
	 **************************************************************************/
digit_first [0-9]+[a-zA-Z|0-9|_]+	


%%
	/**************************************************************************** 
	 *																		    *
	 * 탭(Tab, \t)이나 캐리지 리턴(Carriage return, \r)으로 이루어진                       *
	 * 공백을 무시하기 위한 rule.												        *
	 *																			*
	 ****************************************************************************/
{ws}			;

	/****************************************************************************
	 *																		    *
	 * 2차 과제에서 사용되는 연산자에 대한 rule.							                *
	 *																			*
	 ****************************************************************************/
"+"				{save_token(PLUS, "");}
"-"				{save_token(MINUS, "");}
"*"				{save_token(MUL, "");}
"/"				{save_token(DIV, "");}
"="				{save_token(ASSIGN, "");}

	/****************************************************************************
	 *																		    *
	 * 2차 과제에서 사용되는 기타특수문자에 대한 rule.							                *
	 *																			*
	 ****************************************************************************/
"("				{save_token(LP, "");}
")"				{save_token(RP, "");}
	
	/****************************************************************************
	 *																		    *
	 * 개행문자(new line)에 대한 rule.											    *
	 * 개행 문자가 입력되면 어휘 분석을 종료한다.								                *
	 *																			*
	 ****************************************************************************/
"\n"			{ /* 어휘 분석기를 종료 시킨다 */ return 0;}

	/****************************************************************************
	 *																		    *
	 * 상수에 대한 rule.														    *
	 *																			*
	 ****************************************************************************/
{integer}		{save_token(INT, yytext);}
{real}			{save_token(REAL, yytext);}

	/****************************************************************************
	 *																		    *
	 * 변수 대한 rule.															    *
	 *																		 	*
	 ****************************************************************************/
{digit_first}	{
					//	yyerror(yytext);
					lexical_error_occured = 1;
				}
{under_score}	{
					//	yyerror(yytext);
					lexical_error_occured = 1;
				}
{id}			{save_symbol(yytext); save_token(ID, yytext);}

	/****************************************************************************
	 *																		    *
	 * 위에서 정의한 rule 제외한 나머지는 모두 Lexical Error로 처리하는 rule.	                *
	 *																			*
	 ****************************************************************************/
.				{
					//	yyerror(yytext);
					lexical_error_occured = 1;
				}

%%

int main()
{
	initialize_symbol_table();			// 심볼 테이블을 초기화 한다.

	/****************************************************************************
	 *																		    *
	 * 어휘 분석기를 테스트하기 위한 샘플 프로그램에서							                *
	 * 프롬프트는 무한하게 계속 실행된다고 가정한다.							                *
	 * 따라서 프롬프트를 종료 시키는 과정은 따로 구현하지 않는다. 				                    *
	 *																		    *
	 ****************************************************************************/
	while(!feof(stdin)) {
		initialize_token_list();		// 토큰 리스트를 초기화 한다.	
		printf(">");					// 프롬프트를 출력한다.
		do_lexical_analysis();			// 어휘 분석기를 호출한다.
		if(token_number == 0)			// 아무것도 입력된 토큰이 없을 때 처리
			continue;
//		print_token_list();				// 토큰리스트 출력
		if(lexical_error_occured)		// LEXICAL ERROR 처리
		{
			lexical_error();
			continue;
		}
		do_syntax_analysis();			//SYNTAX ANALYSIS
	}
	fclose(yyin);
	return 0;
}

/***********************************************************************
 *																	   *
 * 함수 이름: initialize_symbol_table								       *
 * 파라미터: 없음													       *
 *																	   * 
 * 심볼 테이블을 초기화 한다.										           *
 *																	   * 
 **********************************************************************/
void initialize_symbol_table() 
{
	for(int i = 0; i < SYMBOL_TABLE_MAX; i++) {
		symbol_table[i].symbol[0] = '\0';
		symbol_table[i].value.integer_constant = 0;
	}
}

/***********************************************************************
 *                                                                     *
 * 함수 이름: initialize_token_list                                       *
 * 파라미터: 없음													       *
 * 리턴 타입: void													       *
 *																	   * 
 * 토큰 리스트를 초기화 한다.										           *
 *															   		   * 
 **********************************************************************/
void initialize_token_list() 
{
	/*내가 추가한 부분
	 새로운 토큰을 받는데 token_number은 0으로 초기화가 안되어서 두번째 입력부터 에러가 남
	 */
	token_number = 0;
	for(int i = 0; i < TOKEN_LIST_MAX; i++) {
		token_list[i].token = 0;
		token_list[i].value[0] = '\0';
	}
}

/***********************************************************************
 *																	   *
 * 함수 이름: do_lexical_analysis									       *
 * 파라미터: 없음													       *
 * 리턴 타입: void													       *
 *																 	   * 
 * 입력한 수식에 대해 어휘를 분석한다.								               *
 *																	   * 
 **********************************************************************/
void do_lexical_analysis()
{
		lexical_error_occured = 0;
		yyin = stdin;
		yylex();
		yyrestart(yyin);
}

/***********************************************************************
 *																	   *
 * 함수 이름: yyerror												       *
 * 파라미터: e(@char*) - 출력할 오류 메시지							           *
 * 리턴 타입: void													       *
 *																	   * 
 * lexical error에 대한 메시지를 출력한다.							           *
 *																	   * 
 **********************************************************************/
void yyerror(char* e)
{
	printf("lexical error: %s\n", e);
}

/***********************************************************************
 *																	   *
 * 함수 이름: save_token											       *
 * 파라미터: token(@TOKEN) - 토큰의 종류							           *
 *			 value(@char*) - 토큰에 해당하는 값						       * 
 * 리턴 타입: void													       *
 *																	   * 
 * 토큰 리스트에 토큰의 종류와 토큰에 해당하는 값을 저장한다.		                       *
 *																	   * 
 **********************************************************************/
void save_token(TOKEN token, char* value)
{
	token_list[token_number].token = token;
	strcpy(token_list[token_number].value, value);
	token_number++;
}

/***********************************************************************
 *																	   *
 * 함수 이름: save_symbol										     	   *
 * 파라미터: symbol(@char*) - 변수(Identifier)						       *
 * 리턴 타입: void													       *
 *																	   * 
 * 심볼 테이블에 심볼과 심볼과 매칭되는 값을 저장한다.				  				   *
 * 중복 되는 심볼은 저장하지 않는다.								               *
 *																	   * 
 **********************************************************************/
void save_symbol(char* symbol)
{
	// 심볼이 중복되지 않는 경우
	if(!is_symbol_duplicated(symbol)) {
		// 심볼 테이블에 저장
		strcpy(symbol_table[symbol_number].symbol, symbol);
		symbol_number++;
	}
}

/***********************************************************************
 *																	   *
 * 함수 이름: is_symbol_duplicated									       *
 * 파라미터: target(@char*) - 중복 체크할 대상인 심볼				               *
 * 리턴 타입: bool													       *
 *																	   *
 * 심볼 테이블에 중복된 심볼이 있는 지 체크한다.					                   *
 *																	   * 
 **********************************************************************/
bool is_symbol_duplicated(char* target)
{
	for(int i = 0; i < symbol_number; i++) {
		// 중복되는 경우
		if(strcmp(symbol_table[i].symbol, target) == 0)
			return true;
	}
	// 중복 안되는 경우
	return false;
}

/****************************************************************************
 *																			*
 * 함수 이름: is_token_duplicated											    *
 * 파라미터: target(@char*) - 중복 체크할 대상인 토큰						            *
 * 리턴 타입: int															    *
 *																			*
 * 심볼 테이블에 일치하는 심볼을 찾아 심볼 테이블 배열의 인덱스를 리턴한다.	                        *
 *																			* 
 ****************************************************************************/
int find_symbol(char* target)
{
	for(int i = 0; i < symbol_number; i++) {
		// 일치하는 심볼을 찾은 경우
		if(strcmp(symbol_table[i].symbol, target) == 0)
			return i;
	}
	return -1;
}

/***********************************************************************
 *																	   *
 * 함수 이름: print_token_list										       *
 * 파라미터: 없음													       *
 * 리턴 타입: void													       *
 *																	   *
 * 입력된 수식에 대해 토큰 리스트를 출력한다.					                       *
 *																	   * 
 **********************************************************************/
void print_token_list()
{
	int symbol_index = 0;
	printf("%s%20s\n", "TOKEN", "LEXEME");
	for(int i = 0; i < token_number; i++) {
		switch(token_list[i].token)
		{
			case INT: printf("%s%16s\n", "INTEGER", token_list[i].value); break;
			case REAL: printf("%s%16s\n", "REAL", token_list[i].value); break;
			case ID:
				if((symbol_index = find_symbol(token_list[i].value)) != -1)
				{
					printf("%s,%d%20s\n", "ID", symbol_index+1, 
									symbol_table[symbol_index].symbol); 
				}
				break;
			case PLUS: printf("%s\n", "PLUS"); break;
			case MINUS: printf("%s\n", "MINUS"); break;
			case MUL: printf("%s\n", "MUL"); break;
			case DIV: printf("%s\n", "DIV"); break;
			case ASSIGN: printf("%s\n", "ASSIGN"); break;
			case LP: printf("%s\n", "LP"); break;
			case RP: printf("%s\n", "RP"); break;
			default: break;
		}
	}
}
void do_syntax_analysis()
{
	double result;
	next_token_idx = 0;
	syntax_error_occured = 0;
	variable_not_defined = 0;
	SYNTAX_NODE * node;
	node = A();
	if(next_token_idx != token_number || syntax_error_occured)
	{
		free_all(node);
		syntax_error();
		return;
	}
	result = calculate(node);
	if(!variable_not_defined)
	{
		printf("%f\n", result);
	}
	//print_tree(node);
	free_all(node);
}
SYNTAX_NODE* A()
{
	SYNTAX_NODE *tmp1, *tmp2, *node;
	if(token_list[next_token_idx].token == ID)
	{
		node = makeNode(ID, NULL, NULL);
		strcpy(node->symbol, token_list[next_token_idx].value);
		match(ID);
		return restA(node);
	}
	else
	{
		tmp1 = restF();
		tmp2 = restT(tmp1);
		return restE(tmp2);
	}
}
SYNTAX_NODE* restA(SYNTAX_NODE* call)
{
	SYNTAX_NODE *tmp1, *tmp2, *node;
	if(token_list[next_token_idx].token == ASSIGN)
	{
		match(ASSIGN);
		tmp1 = A();
		tmp2 = makeNode(ASSIGN, call, tmp1);
		strcpy(tmp2->symbol, "=");
		return tmp2;
	}
	else
	{
		tmp1 = restT(call);
		return restE(tmp1);
	}
}
SYNTAX_NODE* E()
{
	SYNTAX_NODE *node;
	node = T();
	return restE(node);
}
SYNTAX_NODE* restE(SYNTAX_NODE* call)
{
	SYNTAX_NODE *node, *tmp1, *tmp2;
	switch(token_list[next_token_idx].token)
	{
		case PLUS:
			{
				match(PLUS);
				tmp1 = T();
				tmp2 = restE(tmp1);
				node = makeNode(PLUS, call, tmp2);
				strcpy(node->symbol, "+");
				return node;
				break;
			}
		case MINUS:
			{
				match(MINUS);
				tmp1 = T();
				tmp2 = restE(tmp1);
				node = makeNode(MINUS, call, tmp2);
				strcpy(node->symbol, "-");
				return node;
				break;
			}
		default:
			return call;
			break;
	}
}
SYNTAX_NODE* T()
{
	SYNTAX_NODE *node;
	node = F();
	return restT(node);
}
SYNTAX_NODE* restT(SYNTAX_NODE* call)
{
	SYNTAX_NODE *tmp1, *tmp2,*node;
	switch(token_list[next_token_idx].token)
	{
		case MUL:
			{
				match(MUL);
				tmp1 = F();
				tmp2 = restT(tmp1);
				node = makeNode(MUL, call, tmp2);
				strcpy(node->symbol, "*");
				return node;
				break;
			}
		case DIV:
			{
				match(DIV);
				tmp1 = F();
				tmp2 = restT(tmp1);
				node =makeNode(DIV, call, tmp2);
				strcpy(node->symbol, "/");
				return node;
				break;
			}
		default:
			{
				return call;
				break;
			}
	}
}
SYNTAX_NODE* F()
{
	SYNTAX_NODE* node;
	if(token_list[next_token_idx].token == ID)
	{
		node =makeNode(ID, NULL, NULL);
		strcpy(node->symbol, token_list[next_token_idx].value);
		match(ID);
		return node;
	}
	else
	{
		return restF();
	}
}
SYNTAX_NODE* restF()
{
	SYNTAX_NODE *node, *tmp1, *tmp2;
	switch(token_list[next_token_idx].token)
	{
		case LP:
			{
				match(LP);
				node = E();
				if(!match(RP))
				{
					syntax_error_occured = 1;
//					return NULL;
				}
				return node;
			}
		case INT:
			{
				node = makeNode(INT, NULL, NULL);
				strcpy(node->symbol, token_list[next_token_idx].value);
				match(INT);
				return node;
			}
		case REAL:
			{
				node = makeNode(REAL, NULL, NULL);
				strcpy(node->symbol, token_list[next_token_idx].value);
				match(REAL);
				return node;
			}
		case MINUS:
			{
				match(MINUS);
				tmp1 = makeNode(INT, NULL,NULL);
				strcpy(tmp1->symbol, "0");
				tmp2 = F();
				node = makeNode(MINUS, tmp1,tmp2);
				strcpy(node->symbol, "-");
				return node;
			}
		default:
			{
				syntax_error_occured = 1;
				node = makeNode(0,NULL,NULL);
				return node;
//				return NULL;
			}
	}
}


void syntax_error()
{
	printf("%s\n", "error: syntax error");
}
void lexical_error()
{
	printf("%s\n", "error: lexical error");
}
void symbol_not_exist(char *symbol)
{
	printf("%s %s%s\n","error:", symbol, "는 정의되지 않음");
}

SYNTAX_NODE* makeNode(TOKEN tok, SYNTAX_NODE* left, SYNTAX_NODE* right)	
{
	SYNTAX_NODE *node = (SYNTAX_NODE*)malloc(sizeof(SYNTAX_NODE));
	node->token = tok;
	node->Left = left;
	node->Right = right;
	node->symbol[0] = '\0';
	return node;
}

double calculate(SYNTAX_NODE* node)
{
	double res = 0;
	int ID_IDX;
	switch(node->token)
	{
		case INT:
			return atoi(node->symbol);
		case REAL:
			return atof(node->symbol);
		case PLUS:
			{
				return calculate(node->Left) + calculate(node->Right);
			}
		case MINUS:
			{
				return calculate(node->Left) - calculate(node->Right);
			}
		case MUL:
			{
				return calculate(node->Left) * calculate(node->Right);
			}
		case DIV:
			{
				return calculate(node->Left) / calculate(node->Right);
			}
		case ASSIGN:
			{
				ID_IDX=find_symbol(node->Left->symbol);	
				symbol_table[ID_IDX].value.real_constant = calculate(node->Right);
				return symbol_table[ID_IDX].value.real_constant;
			}
		case ID:
			{
				ID_IDX=find_symbol(node->symbol);
				if(symbol_table[ID_IDX].value.real_constant == 0)
				{
					variable_not_defined = 1;
					symbol_not_exist(node->symbol);
					return 0;
				}
				return symbol_table[ID_IDX].value.real_constant;
			}
	}
	return 0;	
}
int match(int expected)
{
	if(token_list[next_token_idx].token ==  expected)
	{
		next_token_idx++;
		return 1;
	}
	else
	{
		next_token_idx++;
		return 0;
	}
}
void free_all(SYNTAX_NODE* node)
{
	if(node->Left != NULL)
	{
		free_all(node->Left);
	}
	if(node->Right != NULL)
	{
		free_all(node->Right);
	}
	free(node);
}
void print_tree(SYNTAX_NODE* node)
{
	printf("%s ", node->symbol);
	if(node->Left != NULL)
		print_tree(node->Left);
	if(node->Right != NULL)
		print_tree(node->Right);

	return;
}
