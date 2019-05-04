%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

#define ERROR_CODE 11

#define NO_KEYWORDS 7
#define ID_LENGTH 50 
#define NO_OPERATOR 11
#define NO_SYMBOL 7

#define INT_MAX_LENGTH 10
#define STRING_LEGNTH 256
#define IDENTIFER_MAX_LENGTH 16
struct symbol{
	char name[ID_LENGTH]; //변수 이름 저장
	void* address; //주소값 저장 (변수의 실제 값을 저장하고 있는 주소
	int type; //어떤 Type인지 저장
	struct symbol* next; //Symbol들을 Linked List로 구현하기 위함
};
struct string_symbol{
	char name[STRING_LEGNTH];
	void* address;
	struct string_symbol* next;
};

struct symbol_table{
	int size;
	struct symbol* first_symbol;
};
struct string_table{
	int size;
	struct string_symbol* first_symbol;
};

//심볼 테이블
struct symbol_table st;
//스트링 테이블
struct string_table sst;

char *keyword[NO_KEYWORDS] = {
	"int", "double", "str", "if", "while", "return", "print"
};
char *keytoken[NO_KEYWORDS] = {
	"INT", "DOUBLE", "STR", "IF", "WHILE", "RETURN", "PRINT"
};

char *operator[NO_OPERATOR] = {
	"+", "-", 
	"*", "/",
	"=", ">", "<", "==", "!=", ">=",
	"<="
	};
char *operatortoken[NO_OPERATOR] = {
	"PLUS", "MINUS",
	"MULTI", "DIV",
	"EQ", "GT", "LT", "IQ", "NQ", "GE",
	"LE"
	};
char *symbol[NO_SYMBOL] = {
	"(", ")", "{", "}",	",", ";","\""
	};
char *symboltoken[NO_SYMBOL] = {
	"LPAREN", "RPAREN", "LBRACE", "RBRACE", "COMMA", "SEMICOLON", "QUOTES"
	};


%}
BLANK			" "+|[\t\n]+
IDENTIFIER		([a-zA-Z]|(_+[0-9A-Za-z]))[_A-Za-z0-9]*
INTEGER			0|([1-9][0-9]*)
DOUBLE			(([0-9]+)|([0-9]*\.[0-9]+))([Ee][-+]?[0-9]+)?
STRING			\"([^\"\\]|\\.)*\"
OPERATOR		([\+\-\*\/])|(\!\=)|([<>\=]\=?)
SYMBOL			\"|\,|\(|\)|\{|\}|\;
COMMENT			\/(\*([^\*]|((\*)+[^\*\/]))*(\*)+\/|(\/[^\n]*\n))
EXCEPTION		.|\n
%%
{BLANK}			{}
{IDENTIFIER}	{ 
					int found = 0; // SYMBOL 찾았는지 확인
					int index = 0; // yytext가 keyword인지 확인하기위함
					int symbol_index=0; //Symbol_table에서 symbol의 위치
					
					int st_index=0; 

					int length = yyleng;
					char tmp[IDENTIFER_MAX_LENGTH+1];
					struct symbol* sb = NULL;
					struct symbol* new = NULL;	
					for(index=0; index<NO_KEYWORDS; index++)
						if(!strcmp(yytext, keyword[index]))
							break;
					if(index<NO_KEYWORDS)
						printf("<%s, >\t\t\t\t %s\n",keytoken[index],yytext); 
					else //IDENRIFER일 경우
					{
						//ID 길이 16로 Cut
						if(length > IDENTIFER_MAX_LENGTH)
						{
							strncpy(tmp, yytext, IDENTIFER_MAX_LENGTH);
							tmp[IDENTIFER_MAX_LENGTH] = '\0';
							length = IDENTIFER_MAX_LENGTH;
							yytext = tmp;
						}
						//ID가 _로 만 이루어졌는지 확인
							if(st.size != 0)
							{
								sb = st.first_symbol;
								//symbol table 검사
								for(st_index =0; st_index< st.size; ++st_index)
								{
									if(!strcmp(sb->name, yytext))
									{
										found = 1;
										symbol_index = st_index+1;
										break;
									}
									if(sb->next != NULL) sb = sb->next;
								}
								if(!found)
								{
									new = (struct symbol*)malloc(sizeof(struct symbol));
									//초기화
									strcpy(new->name, yytext);
									new->next = NULL;
									new->address = NULL;
									new->type = 0;

									sb->next = new;
									st.size++;
									symbol_index = st.size;
								}
							}
							else
							{	
								new = (struct symbol*)malloc(sizeof(struct symbol));
								//초기화
								strcpy(new->name, yytext);
								new->next = NULL;
								new->address = NULL;
								new->type=0;
								st.first_symbol = new;
								st.size++;
								symbol_index = st.size;
							}
						printf("<ID,%d>\t\t\t\t %s\n",symbol_index, yytext);	
					}
				}
{INTEGER}		{
					int length = yyleng;
					char tmp[INT_MAX_LENGTH+1];
					int num;
					if(length > INT_MAX_LENGTH)
					{
						strcpy(tmp, yytext+length-10);
						tmp[INT_MAX_LENGTH] = '\0';
						strcpy(yytext, tmp);
					}
					//printf("LENGTH: %d", length);
					printf("<INTEGER,%s>\t\t\t\t %s\n", yytext, yytext);
				}
{DOUBLE}		{printf("<DOUBLE,%s>\t\t\t\t %s\n", yytext,yytext);}
{STRING}		{
					
					int found = 0;
					int symbol_index=0;
					int sst_index=0;
					struct string_symbol* sb = NULL;
					struct string_symbol* new = NULL;	
					if(sst.size != 0)
					{
							sb = sst.first_symbol;
							//symbol table 검사
							for(sst_index =0; sst_index< sst.size; ++sst_index)
							{
								if(!strcmp(sb->name, yytext))
								{
									found = 1;
									symbol_index = sst_index+1;
									break;
								}
								if(sb->next != NULL) sb = sb->next;
							}
							//table에 포함되지 않았다면
							if(!found)
							{
								new = (struct string_symbol*)malloc(sizeof(struct string_symbol));
								//초기화
								strcpy(new->name, yytext);
								new->next = NULL;
								new->address = NULL;

								sb->next = new;
								sst.size++;
								symbol_index = sst.size;
							}
					}
					//첫 심볼일 때,
					else
					{
							
							new = (struct string_symbol*)malloc(sizeof(struct string_symbol));
							//초기화
							strcpy(new->name, yytext);
							new->next = NULL;
							new->address = NULL;
							sst.first_symbol = new;
							sst.size++;
							symbol_index = sst.size;
					}
						printf("<STRING,%d>\t\t\t\t %s\n",symbol_index,yytext);
				}
{OPERATOR}		{
					int index =0 ;
					for(index=0; index<NO_OPERATOR; index++)
						if(!strcmp(yytext, operator[index]))
							break;
					if(index<NO_OPERATOR)
						printf("<%s, >\t\t\t\t %s\n", operatortoken[index], yytext);
				}	
{SYMBOL}		{
					int index = 0;
					for(index=0; index<NO_SYMBOL; index++)
					if(!strcmp(yytext, symbol[index]))
						break;
					if(index<NO_SYMBOL)
						printf("<%s, >\t\t\t\t %s\n",  symboltoken[index], yytext);
				}
{COMMENT}		{
					printf("<COMMENT>\t\t\t\t %s\n", yytext);
				}
{EXCEPTION}		{printf("<ERROR>\t\t\t\t %s\n", yytext);}

%%
//Print Symbol Table
void print_st();
//Print String Table
void print_sst(); 
int main (int argc, char *argv[])
{
	int free_st = 0; //추후 malloc을 통해 생성한 symbol들 free 할 때 사용하기 위함
	int free_sst =0; //추후 malloc을 통해 생성한 string들 free할 때 사용하기 위함
	st.size = 0;
	st.first_symbol = NULL;
	sst.size=0;
	sst.first_symbol = NULL;

	if (argc > 1)
	{
		FILE *file;
		file = fopen(argv[1], "r");
		if(!file){
			fprintf(stderr, "could not open %s\n", argv[1]);
			exit(1);
		}
		yyin = file;
	}
	printf("TOKEN\t\t\t\t LEXEME\n");
	yylex();
	
	print_st();
	print_sst();
}
//PRINT SYMBOL TABLE
void print_st(){
	int st_idx = 0;
	struct symbol* sb =NULL;
	printf("INDEX\t SYMBOLS\n");
	if(st.size !=0)
		sb = st.first_symbol;
	for(st_idx=0; st_idx < st.size; st_idx++)
	{
		printf("%d\t %s\n",st_idx+1, sb->name);
		if(sb->next !=NULL)
			sb=sb->next;
	}
	printf("\n");
}
//PRINT STRING TABLE
void print_sst(){
	int sst_idx = 0;
	struct string_symbol* sb =NULL;
	printf("INDEX\t STRINGS\n");
	if(sst.size !=0)
		sb = sst.first_symbol;
	for(sst_idx=0; sst_idx < sst.size; sst_idx++)
	{
		printf("%d\t %s\n", sst_idx+1,sb->name);
		if(sb->next !=NULL)
			sb=sb->next;
	}
	printf("\n");
}
