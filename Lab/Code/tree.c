#include "tree.h"
void add(Node* father,int loc,Node* child);
static int depth=-1;
static const char *const types_name_table[] =
{
	/*0 Epsilon*/
	"None",
	/*1 Tokens*/
	"SEMI","COMMA","ASSIGNOP","GT","LT","EQ","GE","LE","NE",
	"PLUS","MINUS","STAR","DIV",
	"AND","OR","DOT","NOT","TYPE",
	"LP","RP","LB","RB","LC","RC",
	"STRUCT","RETURN","IF","ELSE","WHILE","FOR","DO"
	"ID","INT","FLOAT",
	/*2 High-level Definitions*/
	"Program","ExtDefList","ExtDef","ExtDecList",
	/*3 Specifiers*/
	"TypeSpecifier","StructSpecifier","OptTag","Tag",
	/*4 Declarators*/
	"VarDec","FunDec","VarList","ParamDec",
	/*5 Statements*/
	"CompSt","StmtList","Stmt","RepeatStatement","CompoundStatement","ChooseStament",
	/*6 Local Definitions*/
	"VarDeclaration",
	/*7 Expressions*/
	"Expr","Args"
};
const char* get_type_name(Types type)
{
	return types_name_table[type];
}
Node* create_node(Types type)
{
	Node* p=(Node*)malloc(sizeof(Node));
	if(p==NULL)
	{
		printf("Memory allocation error!\n");
		exit(0);
	}
	p->value_i=0;
	p->value_f=0.0;
	p->type=type;
	p->name[0]='\0';
	p->value_c="";
	p->line=-1;
	p->father=NULL;
	p->child_count=0;
	for(int i=0;i<MAX_COUNT_OF_CHILD;i++)
		p->child[i]=NULL;
	return p;
}
void add(Node* father,int loc,Node* child)
{
	father->child[loc]=child;
	child->father=father;
	if(loc==0)
		father->line=child->line;
}
void destroy_tree(Node* head)
{
	if(head==NULL)
		return;
	for(int i=0;i<head->child_count;i++)
		destroy_tree(head->child[i]);
	free(head);
	head=NULL;
}
void construct(Node* father,int n,...)
{
	va_list ap;
	va_start(ap,n);
	father->child_count=n;
	for(int i=0;i<n;i++)
		add(father,i,va_arg(ap,Node*));
}
void print_tree(Node* p)
{
	if(p==NULL)return;
	if(p->line==-1)return;
	depth++;
	if(get_type_name(p->type)=="Program")
		printf("*");
	for(int i=0;i<depth;i++)
		printf("  ");
	if(p->type==_INT||p->type==_FLOAT)
		printf("ConstDeclaration");
	else if(p->type==Expr && p->value_c!="")
		printf("Expr,op:");
	else if(p->type==Expr)
		printf("Expr");
	else
		printf("%s",get_type_name(p->type));
	//根据type索引到type_name
	if(p->type==_ID )
		printf(",symbol: %s",p->name);
	else if(p->type==_TYPE )
		printf(", %s",p->name);
	else if(p->type==_INT)
		printf(", %d",p->value_i);
	else if(p->type==_FLOAT)
		printf(", %f",p->value_f);
	else if(p->type==Expr)
		printf(" %s",p->value_c);
	//这部分打印的是id名，int类型数据的值什么的
	printf("\n");
	for(int i=0;i<p->child_count;i++)
		print_tree(p->child[i]);
	depth--;
}
