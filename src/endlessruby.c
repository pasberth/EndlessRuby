#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[])
{
  int i = 0;
  if(argc == 1)
    {
      puts("EndlessRuby need main file name\0");
      return 0;
    }

  char er[] = "endlessruby.rb";

  int size = sizeof(er);
  for(i = 1; i < argc; i++)
    {
      size += sizeof(" ");
      size += sizeof(argv[i]);
    }
  size += sizeof("\0");

  char *cmd = (char *) malloc(size);
  strcat(cmd, er);
  for(i = 1; i < argc; i++)
    {
      strcat(cmd, " ");
      strcat(cmd, argv[i]);
    }
  strcat(cmd, "\n");

  system(cmd);

  return 0;
}
