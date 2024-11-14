%{                                                                                                                                                                      

#include <stdio.h>                                                                                                                                                      

#include <stdlib.h>                                                                                                                                                     

#include <string.h>                                                                                                                                                     



void yyerror(const char *s);                                                                                                                                            

extern int yylex();                                                                                                                                                     

extern int yyparse();                                                                                                                                                   

char **headers;                                                                                                                                                         

int header_count;                                                                                                                                                       

int original_header_count;  // Added to track the original number of headers                                                                                            

FILE *output_file;  // File pointer for output                                                                                                                          

%}                                                                                                                                                                      



%union {                                                                                                                                                                

    char *str;                                                                                                                                                          

}                                                                                                                                                                       



%token COMMA NEWLINE                                                                                                                                                    
%token <str> STRING                                                                                                                                                     

%type <str> file rows row fields field                                                                                                                                  



%%                                                                                                                                                                      

file: headers NEWLINE rows {                                                                                                                                            

        fprintf(output_file, "[\n%s\n]\n", $3); 
	printf("[\n%s\n]\n",$3);															

    }                                                                                                                                                                   

    | /* empty */ {                                                                                                                                                     

        fprintf(output_file, "[]\n");                                                                                                                                   

        $$ = strdup("");
	printf("[]\n");																		

    }                                                                                                                                                                   

;                                                                                                                                                                       



headers: STRING {                                                                                                                                                       

        headers = (char **) malloc(sizeof(char *) * 1);                                                                                                                 

        headers[0] = $1;                                                                                                                                                

        header_count = 1;                                                                                                                                               

        original_header_count = header_count;  // Track the original header count                                                                                       

    }                                                                                                                                                                   
    | headers COMMA STRING {                                                                                                                                            

        headers = (char **) realloc(headers, sizeof(char *) * (header_count + 1));                                                                                      

        headers[header_count] = $3;                                                                                                                                     

        header_count++;                                                                                                                                                 

        original_header_count = header_count;  // Update the original header count                                                                                      

    }                                                                                                                                                                   

;                                                                                                                                                                       



rows: row NEWLINE rows {                                                                                                                                                
        $$ = (char *) malloc(strlen($1) + strlen($3) + 3);                                                                                                              

        sprintf($$, "%s,\n%s", $1, $3);                                                                                                                                 

    }                                                                                                                                                                   

    | row {                                                                                                                                                             

        $$ = $1;                                                                                                                                                        

    }                                                                                                                                                                   

    | row NEWLINE {                                                                                                                                                     

        $$ = $1;                                                                                                                                                        

    }                                                                                                                                                                   

;                                                                                                                                                                       



row: fields {                                                                                                                                                           

        header_count = original_header_count;  // Reset header_count for new row                                                                                        

        char *json_row = (char *) malloc(strlen($1) + 7);                                                                                                               

        sprintf(json_row, "  {\n%s\n  }", $1);                                                                                                                          

        $$ = json_row;                                                                                                                                                  

    }                                                                                                                                                                   

;                                                                                                                                                                       


fields: field COMMA fields {                                                                                                                                            

        char *json_field = (char *) malloc(strlen($1) + strlen($3) + 3);                                                                                                

        sprintf(json_field, "%s,\n%s", $1, $3);                                                                                                                         

        $$ = json_field;                                                                                                                                                

    }                                                                                                                                                                   

    | field {                                                                                                                                                           

        $$ = $1;                                                                                                                                                        

    }                                                                                                                                                                   

;                                                                                                                                                                       


field: STRING {                                                                                                                                                         

        if (header_count > 0) {                                                                                                                                         

            char *json_field = (char *) malloc(strlen(headers[original_header_count - header_count]) + strlen($1) + 12);                                                


            sprintf(json_field, "    \"%s\": \"%s\"", headers[original_header_count - header_count], $1);                                                               

            header_count--;  // Decrease for next field in the row                                                                                                      

            $$ = json_field;                                                                                                                                            

        } else {                                                                                                                                                        

            yyerror("Field count exceeds the number of headers.");                                                                                                      

            $$ = strdup("");  // Return empty string if mismatch occurs                                    

        }                                                                                                                                                               

    }                                                                                                                                                                   

;                                                                                                                                                                       



%%                                                                                                                                                                      



void yyerror(const char *s) {                                                                                                                                           

    fprintf(stderr, "Error: %s\n", s);                                                                                                                                  

}                                                                                                                                                                       



int main() {                                                                                                                                                            

    output_file = fopen("output.json", "w");                                                                                                                            

    if (!output_file) {                                                                                                                                                 

        fprintf(stderr, "Error: Could not open output.json for writing.\n");                                                                                            

        exit(1);                                                                                                                                                        

    }                                                                                                                                                                   



    yyparse();                                                                                                                                                          
    fclose(output_file);  // Close the file after parsing is complete                                                                                                   

    return 0;                                                                                                                                                           

}
