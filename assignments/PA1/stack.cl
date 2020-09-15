(*
 *  CS164 Fall 94
 *
 *  Programming Assignment 1
 *    Implementation of a simple stack machine.
 *
 *  Skeleton file
 *)

class StackCommand {

   getChar(): String {
      "Called from base class"
   };

   execute(node: StackNode): StackNode {
      let ret: StackNode in {
         (new IO).out_string("Undefined execution!\n");
         ret;
      }
   };

   getNumber(): Int {
      0
   };
};

class IntCommand inherits StackCommand {
   number: Int;

   init(num: Int): SELF_TYPE {
      {
         number <- num;
         self;
      }
   };

   execute(node: StackNode): StackNode {
      node
   };

   getNumber(): Int {
      number
   };

   getChar(): String {
      (new A2I).i2a(number)
   };
};

class PlusCommand inherits StackCommand {
   init(): SELF_TYPE {
      self
   };

   execute(node: StackNode): StackNode {
      let n1: StackNode <- node.getNext(),
         n2: StackNode <- n1.getNext(),
         sum: Int,
         ret: StackNode in {
            if (not (isvoid n1)) then
               if (not (isvoid n2)) then {
                  sum <- n1.getCommand().getNumber() + n2.getCommand().getNumber();
                  ret <- (new StackNode).init((new IntCommand).init(sum), n2.getNext());
               } 
               else 
                  0
               fi
            else
               0
            fi;
            ret;
         }
   };

   getChar(): String {
      "+"
   };
};

class SwapCommand inherits StackCommand {
   init(): SELF_TYPE {
      self
   };

   execute(node: StackNode): StackNode {
      let next: StackNode <- node.getNext().getNext() in {
         node <- node.getNext();
         node.setNext(next.getNext());
         next.setNext(node);
         next;
      }
   };

   getChar(): String {
      "s"
   };
};

class StackNode {
   command : StackCommand;
   next : StackNode;

   init(co: StackCommand, ne: StackNode): StackNode {
      {
         command <- co;
         next <- ne;
         self;
      }
   };

   putOnTop(co: StackCommand): StackNode {
      let newNode: StackNode in {
         newNode <- (new StackNode).init(co, self);
         newNode;
      }
   };

   getCommand(): StackCommand {
      {
         command;
      }
   };

   getNext(): StackNode {
      {
         next;
      }
   };

   setNext(node: StackNode): StackNode {
      next <- node
   };
};

class Main inherits A2I {

   -- testStackCommand() : Object {
   --    let intCommand: IntCommand <- (new IntCommand).init(2),
   --       nil: StackNode
   --    in {
   --       intCommand.execute(nil);
   --    }
   -- };

   stackTop: StackNode;

   printStack(): Object {
      let node: StackNode <- stackTop in {
         while (not (isvoid node)) loop
         {
            (new IO).out_string(node.getCommand().getChar());
            (new IO).out_string("\n");
            node <- node.getNext();
         }
         pool;
      }
   };

   pushCommand(command: StackCommand): StackCommand {
      {
         if (isvoid stackTop) then {
            let nil: StackNode in {
               stackTop <- (new StackNode).init(command, nil);
            };
         } else {
            stackTop <- stackTop.putOnTop(command);
         } fi;
         command;
      }
   };

   popCommand(): StackCommand {
      let ret: StackCommand <- stackTop.getCommand() in {
         stackTop <- stackTop.getNext();
         ret;
      }
   };

   executeStackMachine(inString: String): Object {
      {
         if (inString = "+") then
         {
            pushCommand((new PlusCommand).init());
         }
         else
            if (inString = "s") then
               pushCommand((new SwapCommand).init())
            else
               if (inString = "d") then
                  printStack()
               else
                  if (inString = "x") then
                     -- stop
                     {
                        (new IO).out_string("stop!\n");
                        abort();
                     }
                  else
                     if (inString = "e") then
                        let node: StackNode <- stackTop in {
                           if (not (isvoid node)) then
                              stackTop <- node.getCommand().execute(node)
                           else
                              0
                           fi;
                        }
                     else
                        pushCommand((new IntCommand).init((new A2I).a2i(inString)))
                     fi
                  fi
               fi
            fi
         fi;
      }
   };

   main() : Object {
      let inString: String in {
         while (true) loop
         {
            (new IO).out_string(">");
            inString <- (new IO).in_string();
            executeStackMachine(inString);
         }
         pool;
      }
   };

};
