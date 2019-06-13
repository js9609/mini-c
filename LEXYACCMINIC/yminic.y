%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <malloc.h>
#include "struct.h"
extern int yylex();
extern int yyerror(char *);


int ST_IDX = 0;

		struct SN{
			char symbol[SYMBOL_MAX+1];
			union{
				double real_constant;
				int integer_constant;
			}value;
			TOKEN token;
			struct SN* expr; //조건문 넣는곳
			struct SN* Left;
			struct SN* Right;
		};
typedef struct SN SYNTAX_NODE;
SYMBOL_TABLE symbol_table[SYMBOL_TABLE_MAX];	// 사이즈가 100인 심볼 테이블 배열
SYNTAX_NODE* create_node(TOKEN tok, SYNTAX_NODE* left, SYNTAX_NODE* right); //ASSIGN, IS_TRUE, 가감승제
SYNTAX_NODE* create_snode(TOKEN tok, char* cval); //create singlenode, int ,real, id
SYNTAX_NODE* create_fnode(TOKEN tok, SYNTAX_NODE* expr, SYNTAX_NODE* left, SYNTAX_NODE* right);


int is_symbol_duplicated(char* target);
void save_symbol(char* symbol);
void fun_do(SYNTAX_NODE* node);
void free_node(SYNTAX_NODE* node);
void fun_assign(SYNTAX_NODE* var, SYNTAX_NODE* expr);
int find_var(char* var); // return index of the var
void print_stat(SYNTAX_NODE* node);
void control_stat(SYNTAX_NODE* node);
%}
%union {
	char* cval;
	struct SN* psn;
};
%token <cval>INT
%token <cval> REAL
%token <cval> ID

%token PLUS MINUS MUL DIV GT GE LT LE EE NE
%token ASSIGN
%token IF ELSE PRINT WHILE

%type <psn> expr value variable stat if_stat control_stat while_stat print_stat

%left PLUS MINUS
%left MUL DIV
%left GT GE LT LE EE NE
%left '(' ')'

%right ASSIGN
%start stat_list

%%
stat_list: /*empty */
	|stat_list stat{
		fun_do($2);
		free_node($2);
	}
	;
stat:expr';'{
		$$ = $1;
	}
	|print_stat{
		 $$ = $1;
	}
	|control_stat{
		 $$ = $1;
	}
	;
print_stat: PRINT expr ';'{
				$$ = create_fnode(T_PRINT, $2, NULL, NULL);
			}
	;
control_stat: if_stat {$$ =$1;}
	|while_stat {$$ = $1;}
	;
if_stat: IF '(' expr ')' stat ELSE stat {
			   $$ = create_fnode(T_IF, $3, $5, $7);
		   }
	;
while_stat:WHILE '(' expr ')' stat{
				$$ = create_fnode(T_WHILE, $3, $5, NULL);
	}
	;

expr:	value {$$ = $1;}
	|variable { $$ = $1;}
	|variable ASSIGN expr {$$ = create_node(T_ASSIGN, $1, $3);}
	|expr PLUS expr {$$ = create_node(T_PLUS, $1, $3);}
	|expr MINUS expr {$$ = create_node(T_MINUS, $1, $3);}
	|expr MUL expr {$$ = create_node(T_MUL, $1, $3);}
	|expr DIV expr {$$ = create_node(T_DIV, $1, $3);}
	|expr GT expr {$$ = create_node(T_GT, $1, $3);}
	|expr GE expr {$$ = create_node(T_GE, $1, $3);}
	|expr LT expr {$$ = create_node(T_LT, $1, $3);}
	|expr LE expr {$$ = create_node(T_LE, $1, $3);}
	|expr EE expr {$$ = create_node(T_EE, $1, $3);}
	|expr NE expr {$$ = create_node(T_NE, $1, $3);}
	|'(' expr ')' {$$ = $2;}
	;
value: INT {$$ = create_snode(T_INT, $1);}
	| REAL {$$ = create_snode(T_REAL,$1);}
	;
variable: ID {$$ = create_snode(T_ID,$1);}
	;
%%


SYNTAX_NODE* create_node(TOKEN tok, SYNTAX_NODE* left, SYNTAX_NODE* right) //ASSIGN, IS_TRUE, 가감승제
{
	SYNTAX_NODE *node = (SYNTAX_NODE*)malloc(sizeof(SYNTAX_NODE));
	node->token = tok;
	node->Left = left;
	node->Right = right;
	node->symbol[0] = '\0';
	node->expr = NULL;
	return node;
}
SYNTAX_NODE* create_snode(TOKEN tok, char* cval)
{
	SYNTAX_NODE *node = (SYNTAX_NODE*)malloc(sizeof(SYNTAX_NODE));
	strcpy(node->symbol, cval);
	node->token = tok;
	node->Left = NULL;
	node->Right = NULL;
	node->expr = NULL;
	return node;
}

SYNTAX_NODE* create_fnode(TOKEN tok, SYNTAX_NODE* expr, SYNTAX_NODE* left, SYNTAX_NODE* right)
{
	
	SYNTAX_NODE *node = (SYNTAX_NODE*)malloc(sizeof(SYNTAX_NODE));
	node->token = tok;
	node->Left = left;
	node->Right = right;
	node->expr = expr;
	node->symbol[0] = '\0';
	return node;
}
void fun_do(SYNTAX_NODE* node)
{
	int idx = -1;
	if(node == NULL)
	{
		return;
	}

	switch(node->token)
	{
		case T_PLUS:
			{
				fun_do(node->Left);
				fun_do(node->Right);
				node->value.real_constant = node->Left->value.real_constant + node->Right->value.real_constant;		
				break;
			}
		case T_MINUS:
			{
	
				fun_do(node->Left);
				fun_do(node->Right);
				node->value.real_constant = node->Left->value.real_constant - node->Right->value.real_constant;		
				break;
			}
		case T_MUL:
			{
			
				fun_do(node->Left);
				fun_do(node->Right);
				node->value.real_constant = node->Left->value.real_constant * node->Right->value.real_constant;		
				break;
			}
		case T_DIV:
			{
				fun_do(node->Left);
				fun_do(node->Right);
				node->value.real_constant = node->Left->value.real_constant / node->Right->value.real_constant;		
				break;
		
			}
		case T_ASSIGN:
			{	
				fun_assign(node->Left, node->Right);
				node->value.real_constant = node->Left->value.real_constant;
				break;
			}
		case T_GT:
			{				
				fun_do(node->Left);
				fun_do(node->Right);
				if(node->Left->value.real_constant > node->Right->value.real_constant)
					node->value.real_constant = 1;
				else
					node->value.real_constant = 0;
				break;
			}
		case T_GE:
			{
				fun_do(node->Left);
				fun_do(node->Right);
				if(node->Left->value.real_constant >= node->Right->value.real_constant)
					node->value.real_constant = 1;
				else
					node->value.real_constant = 0;
				break;
			}
		case T_LT:
			{
				fun_do(node->Left);
				fun_do(node->Right);
				if(node->Left->value.real_constant < node->Right->value.real_constant)
					node->value.real_constant = 1;
				else
					node->value.real_constant = 0;
				break;

			}
		case T_LE:
			{
				fun_do(node->Left);
				fun_do(node->Right);
				if(node->Left->value.real_constant <= node->Right->value.real_constant)
					node->value.real_constant = 1;
				else
					node->value.real_constant = 0;
				break;
			}
		case T_EE:
			{
				fun_do(node->Left);
				fun_do(node->Right);
				if(node->Left->value.real_constant == node->Right->value.real_constant)
					node->value.real_constant = 1;
				else
					node->value.real_constant = 0;
				break;
			}
		case T_NE:
			{
				fun_do(node->Left);
				fun_do(node->Right);
				if(node->Left->value.real_constant != node->Right->value.real_constant)
					node->value.real_constant = 1;
				else
					node->value.real_constant = 0;
				break;
			}
		case T_ID:
			{
				save_symbol(node->symbol);
				node->value.real_constant = symbol_table[find_var(node->symbol)].value.real_constant;
				break;
			}
		case T_INT:
			{
				node->value.real_constant = atoi(node->symbol);
				break;
			}
		case T_REAL:
			{	
				node->value.real_constant = atol(node->symbol);
				break;
			}
		case T_PRINT:
			{
				print_stat(node);
				break;
			}
		case T_IF:
			{
				control_stat(node);
				break;
			}
		case T_WHILE:
			{
				control_stat(node);
				break;
			}
		default:
			{
				break;
			}
	
	}


}
void print_stat(SYNTAX_NODE* node)
{
	fun_do(node->expr);
	node->value.real_constant = node->expr->value.real_constant;
	printf("%f\n", node->value.real_constant);
}
void control_stat(SYNTAX_NODE* node)
{
	if(node == NULL)
		return;

	fun_do(node->expr);
	if(node->token == T_IF)
	{	
		if(node->expr->value.real_constant > 0)
			fun_do(node->Left);
		else
			fun_do(node->Right);
	}
	else if(node->token == T_WHILE)
	{
		while(node->expr->value.real_constant > 0)
		{
			fun_do(node->Left);
			fun_do(node->expr);
		}
	}

}
void fun_assign(SYNTAX_NODE* var, SYNTAX_NODE* expr)
{
	int idx = -1;
	fun_do(var);
	fun_do(expr);
	save_symbol(var->symbol);
	var->value.real_constant = expr->value.real_constant;
	idx = find_var(var->symbol);
	symbol_table[idx].value.real_constant = var->value.real_constant;	
}
int find_var(char* var) // return index of the var
{
		for(int i = 0; i < ST_IDX; i++) {
		// 일치하는 심볼을 찾은 경우
		if(strcmp(symbol_table[i].symbol, var) == 0)
			return i;
	}
	return -1;
}
void free_node(SYNTAX_NODE* node)
{
	if(node->Left != NULL)
	{
		free_node(node->Left);
	}
	if(node->Right != NULL)
	{
		free_node(node->Right);
	}
	free(node);
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
	//	printf("%s", "심볼 테이블에 저장되었습니다.");
		strcpy(symbol_table[ST_IDX].symbol, symbol);
		ST_IDX++;
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
int is_symbol_duplicated(char* target)
{
	for(int i = 0; i < ST_IDX; i++) {
		// 중복되는 경우
		if(strcmp(symbol_table[i].symbol, target) == 0)
			return 1;
	}
	// 중복 안되는 경우
	return 0;
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
int yyerror (char *s) {fprintf (stderr, "%s\n", s);}
int main(void)
{
	return  yyparse();
}

