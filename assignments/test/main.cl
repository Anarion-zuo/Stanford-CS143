(*
 *  CS164 Fall 94
 *
 *  Programming Assignment 1
 *    Implementation of a simple stack machine.
 *
 *  Skeleton file
 *)

class ListNode {
   item: String;
   next: List;
   
   init(i: String, n: List) : List {
      item <- i;
      next <- n;
      self;
   };

   getNext() : List {
      next;
   };

   getItem() : String {
      item;
   }
}

class Main inherits A2I {

   main() : Object {
	   	-- (new IO).out_string(i2a(fact(a2i((new IO).in_string()))).concat("\n"))
	   	(new IO).out_string(i2a(factLoop(a2i((new IO).in_string()))).concat("\n"))
   };

   fact(i : Int) : Int {
	   if (i = 0) then 1 else i * fact(i - 1) fi
   };

   factLoop(i: Int): Int {
      let ret: Int <- 1 in {
         while (not (i = 0)) loop 
         {
            ret <- ret * i;
            i <- i - 1;
         }
         pool;
         ret;
      }
   };

};
