%{
#include "lex.yy.c"
#ifndef YYSTYPE
#define YYSTYPE Node*
#endif
#define YYERROR_VERBOSE 1
Node* head=NULL;
int yyerror(const char* msg);
void m_yyerror(char* msg,int lineno);
char message[100];
%}
%locations
/*1 Tokens*/
%token SEMI COMMA ASSIGNOP GT LE LT EQ NE GE  
%token PLUS MINUS STAR DIV 
%token AND OR DOT NOT TYPE 
%token LP RP LB RB LC RC 
%token STRUCT RETURN IF ELSE WHILE FOR DO
%token ID INT FLOAT
/*优先级，结合性*/
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE
%right ASSIGNOP
%left OR
%left AND
%left RELOP
%left PLUS MINUS
%left STAR DIV
%right NOT
%left DOT LP RP LB RB
%%
/*2 High-level Definitions*/
Program : ExtDefList {$$=create_node(Program);construct($$,1,$1);head=$$;}
	;
ExtDefList : ExtDef ExtDefList {$$=create_node(ExtDefList);construct($$,2,$1,$2);}
	| /* empty */ {$$=create_node(ExtDefList);construct($$,1,create_node(None));}
	;
ExtDef : TypeSpecifier ExtDecList SEMI {$$=create_node(ExtDef);construct($$,3,$1,$2,$3);}
	| TypeSpecifier SEMI {$$=create_node(ExtDef);construct($$,2,$1,$2);}
	| TypeSpecifier FunDec CompSt {$$=create_node(ExtDef);construct($$,3,$1,$2,$3);}
	| TypeSpecifier error SEMI {$$=create_node(ExtDef);construct($$,3,$1,create_node(None),$3);
							m_yyerror("something wrong with ExtDecList before \";\"",@2.last_line);}
	| error SEMI {$$=create_node(ExtDef);construct($$,2,create_node(None),$2);
					m_yyerror("something wrong with Specifier before \";\"",@1.last_line);}
	;
ExtDecList : VarDec {$$=create_node(ExtDecList);construct($$,1,$1);}
	| VarDec COMMA ExtDecList {$$=create_node(ExtDecList);construct($$,3,$1,$2,$3);}
	;
/*3 Specifiers*/
TypeSpecifier : TYPE {$$=create_node(TypeSpecifier);construct($$,1,$1);}
	| StructSpecifier {$$=create_node(TypeSpecifier);construct($$,1,$1);}
	;
StructSpecifier : STRUCT OptTag LC VarDeclaration RC {$$=create_node(StructSpecifier);construct($$,5,$1,$2,$3,$4,$5);}
	| STRUCT Tag {$$=create_node(StructSpecifier);construct($$,2,$1,$2);}
	;
OptTag : ID {$$=create_node(OptTag);construct($$,1,$1);}
	| /* empty */ {$$=create_node(OptTag);construct($$,1,create_node(None));}
	;
Tag : ID {$$=create_node(Tag);construct($$,1,$1);}
	;
/*4 Declarators*/
VarDec : ID {$$=create_node(VarDec);construct($$,1,$1);}
	| VarDec LB INT RB {$$=create_node(VarDec);construct($$,4,$1,$2,$3,$4);}
	| VarDec LB error RB {$$=create_node(VarDec);construct($$,4,$1,$2,create_node(None),$4);
							m_yyerror("missing a integer between []",@3.last_line);}
	;
FunDec : ID LP VarList RP {$$=create_node(FunDec);construct($$,4,$1,$2,$3,$4);}
	| ID LP RP {$$=create_node(FunDec);construct($$,3,$1,$2,$3);}
	| ID LP error RP {$$=create_node(FunDec);construct($$,4,$1,$2,create_node(None),$4);
						m_yyerror("something wrong with VarList between ()",@3.last_line);}
	| ID error RP {$$=create_node(FunDec);construct($$,3,$1,create_node(None),$3);
					m_yyerror("missing \"(\"",@2.last_line);}
	;
VarList : ParamDec COMMA VarList {$$=create_node(VarList);construct($$,3,$1,$2,$3);}
	| ParamDec {$$=create_node(VarList);construct($$,1,$1);}
	| error COMMA VarList {$$=create_node(VarList);construct($$,3,create_node(None),$2,$3);
							m_yyerror("something wrong with ParamDec",@1.last_line);}
	;
ParamDec : TypeSpecifier VarDec {$$=create_node(ParamDec);construct($$,2,$1,$2);}
	;
/*5 Statements*/
CompSt : LC VarDeclaration StmtList RC {$$=create_node(CompSt);construct($$,4,$1,$2,$3,$4);}
	| error RC {$$=create_node(CompSt);construct($$,2,create_node(None),$2);
				m_yyerror("Missing \"{\"",@1.first_line);}
	;
StmtList : Stmt StmtList {$$=create_node(StmtList);construct($$,2,$1,$2);}
	| /* empty */ {$$=create_node(StmtList);construct($$,1,create_node(None));}
	;
Stmt : Expr SEMI {$$=create_node(Stmt);construct($$,2,$1,$2);}
	| error SEMI {$$=create_node(Stmt);construct($$,2,create_node(None),$2);
					m_yyerror("something wrong with expression before \";\"",@1.last_line);}
	| CompSt {$$=create_node(Stmt);construct($$,1,$1);}
	| RETURN Expr SEMI {$$=create_node(Stmt);construct($$,3,$1,$2,$3);}
	| RETURN error SEMI {$$=create_node(Stmt);construct($$,3,$1,create_node(None),$3);
						m_yyerror("something wrong with expression before \";\"",@2.last_line);}
	| IF LP Expr RP Stmt %prec LOWER_THAN_ELSE {$$=create_node(Stmt);construct($$,5,$1,$2,$3,$4,$5);}
	| IF LP error RP Stmt %prec LOWER_THAN_ELSE{$$=create_node(Stmt);construct($$,5,$1,$2,create_node(None),$4,$5);
												m_yyerror("something wrong with expression between ()",@3.last_line);}
	| IF LP Expr RP Stmt ELSE Stmt {$$=create_node(Stmt);construct($$,7,$1,$2,$3,$4,$5,$6,$7);}
	| IF LP Expr RP error ELSE Stmt {$$=create_node(Stmt);construct($$,7,$1,$2,$3,$4,create_node(None),$6,$7);
									m_yyerror("Missing \";\"",@5.last_line);}
	| IF LP error RP Stmt ELSE Stmt {$$=create_node(Stmt);construct($$,7,$1,$2,create_node(None),$4,$5,$6,$7);
									m_yyerror("something wrong with expression between ()",@3.last_line);}
	| IF error RP Stmt %prec LOWER_THAN_ELSE {$$=create_node(Stmt);construct($$,4,$1,create_node(None),$3,$4);
												m_yyerror("missing \"(\"",@2.last_line);}
	| IF error RP Stmt ELSE Stmt {$$=create_node(Stmt);construct($$,6,$1,create_node(None),$3,$4,$5,$6);
									m_yyerror("missing \"(\"",@2.last_line);}
	;
//循环语句部分
RepeatStatement: WHILE LP Expr RP StmtCompoundStatement {$$=create_node(RepeatStatement);construct($$,5,$1,$2,$3,$4,$5);}
	| WHILE LP error RP CompoundStatement {$$=create_node(RepeatStatement);construct($$,5,$1,$2,create_node(None),$4,$5);
							m_yyerror("something wrong with expression between ()",@3.last_line);}
	| WHILE error RP CompoundStatement {$$=create_node(RepeatStatement);construct($$,4,$1,create_node(None),$3,$4);
							m_yyerror("missing \"(\"",@2.last_line);}
	| FOR LP Expr SEMI Expr SEMI Expr RP CompoundStatement { $$=create_node(RepeatStatement);;construct($$,9,$1,$2,$3,$4,$5,$6,$7,$8,$9);}
	| FOR LP SEMI Expr SEMI Expr RP CompoundStatement { $$=create_node(RepeatStatement);;construct($$,8,$1,$2,$3,$4,$5,$6,$7,$8);}
	| FOR LP Expr SEMI SEMI Expr RP CompoundStatement { $$=create_node(RepeatStatement);;construct($$,8,$1,$2,$3,$4,$5,$6,$7,$8);}
	| FOR LP Expr SEMI Expr SEMI RP CompoundStatement { $$=create_node(RepeatStatement);;construct($$,8,$1,$2,$3,$4,$5,$6,$7,$8);}
	| FOR LP SEMI SEMI Expr RP CompoundStatement { $$=create_node(RepeatStatement);;construct($$,7,$1,$2,$3,$4,$5,$6,$7);}
	| FOR LP SEMI Expr SEMI RP CompoundStatement { $$=create_node(RepeatStatement);;construct($$,7,$1,$2,$3,$4,$5,$6,$7);}
	| FOR LP Expr SEMI SEMI RP CompoundStatement { $$=create_node(RepeatStatement);;construct($$,7,$1,$2,$3,$4,$5,$6,$7);}
	| FOR LP SEMI SEMI RP CompoundStatement { $$=create_node(RepeatStatement);;construct($$,6,$1,$2,$3,$4,$5,$6);}
//这里还有一些问题，就是没有for循环的错误情况处理
CompoundStatement: Stmt {$$=create_node(CompoundStatement);;construct($$,1,$1);}
	|RepeatStament {$$=create_node(CompoundStatement);;construct($$,1,$1);}
//这里补充的是循环里面循环体的声明
//下面是条件选择的部分


/*6 Local Definitions*/
VarDeclaration : TypeSpecifier Expr SEMI{$$=create_node(VarDeclaration);construct($$,2,$1,$2);}
	| TypeSpecifier Expr COMMA Expr SEMI{$$=create_node(VarDeclaration);construct($$,3,$1,$2,$4);}
	| /* empty */ {$$=create_node(VarDeclaration);construct($$,1,create_node(None));}
	;
/*7 Expressions*/
Expr : Expr ASSIGNOP Expr {$$=create_node(Expr);$$->value_c="=";construct($$,2,$1,$3);}
	| Expr AND Expr {$$=create_node(Expr);$$->value_c="&&";construct($$,2,$1,$3);}
	| Expr OR Expr {$$=create_node(Expr);$$->value_c="||";construct($$,2,$1,$3);}
	| Expr GT Expr {$$=create_node(Expr);$$->value_c=">";construct($$,2,$1,$3);}
	| Expr LT Expr {$$=create_node(Expr);$$->value_c="<";construct($$,2,$1,$3);}
	| Expr EQ Expr {$$=create_node(Expr);$$->value_c="==";construct($$,2,$1,$3);}
	| Expr GE Expr {$$=create_node(Expr);$$->value_c=">=";construct($$,2,$1,$3);}
	| Expr LE Expr {$$=create_node(Expr);$$->value_c="<=";construct($$,2,$1,$3);}
	| Expr NE Expr {$$=create_node(Expr);$$->value_c="!=";construct($$,2,$1,$3);}	
	| Expr PLUS Expr {$$=create_node(Expr);$$->value_c="+";construct($$,2,$1,$3);}
	| Expr MINUS Expr {$$=create_node(Expr);$$->value_c="-";construct($$,2,$1,$3);}
	| Expr STAR Expr {$$=create_node(Expr);$$->value_c="*";construct($$,2,$1,$3);}
	| Expr DIV Expr {$$=create_node(Expr);$$->value_c="/";construct($$,2,$1,$3);}
	| LP Expr RP {$$=create_node(Expr);construct($$,3,$1,$2,$3);}
	| MINUS Expr %prec NOT {$$=create_node(Expr);construct($$,2,$1,$2);}
	| NOT Expr {$$=create_node(Expr);construct($$,2,$1,$2);}
	| ID LP Args RP {$$=create_node(Expr);construct($$,4,$1,$2,$3,$4);}
	| ID LP RP {$$=create_node(Expr);construct($$,3,$1,$2,$3);}
	| Expr LB Expr RB {$$=create_node(Expr);construct($$,4,$1,$2,$3,$4);}
	| Expr DOT ID {$$=create_node(Expr);construct($$,3,$1,$2,$3);}
	| ID {$$=create_node(Expr);construct($$,1,$1);}
	| INT {$$=create_node(Expr);construct($$,1,$1);}
	| FLOAT {$$=create_node(Expr);construct($$,1,$1);}
	| error RP {$$=create_node(Expr);construct($$,2,create_node(None),$2);
				m_yyerror("missing \"(\"",@1.last_line);}
	| Expr LB error RB {$$=create_node(Expr);construct($$,4,$1,$2,create_node(None),$4);
				m_yyerror("missing \"]\"",@3.last_line);}
	| ID error RP {$$=create_node(Expr);construct($$,3,$1,create_node(None),$3);
				m_yyerror("missing \"(\"",@2.last_line);}
	;
Args : Expr COMMA Args {$$=create_node(Args);construct($$,3,$1,$2,$3);}
	| Expr {$$=create_node(Args);construct($$,1,$1);}
	| error COMMA Args {$$=create_node(Args);construct($$,3,create_node(None),$2,$3);
						m_yyerror("something wrong with your expression",@1.last_line);}
	;
%%
int main(int argc,char** argv)
{
	if(argc!=2)
	{
		printf("请输入且仅输入一个文件。\n");
		return 1;
	}
	FILE* f=fopen(argv[1],"r");
	if (f==NULL)
	{
		printf("无法打开文件 %s\n",argv[1]);
		return 1;
	}
	yyrestart(f);
	if(yyparse()==0 && !error_occured)
		print_tree(head);
	destroy_tree(head);
	fclose(f);
	return 0;
}
int yyerror(const char* msg) {
strcpy(message,msg+14);
error_occured=true;
}
void m_yyerror(char* msg,int lineno) {
printf("Error type B at Line %d: %s, maybe %s.\n",lineno,message,msg);
error_occured=true;
}
