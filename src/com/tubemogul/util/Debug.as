package com.tubemogul.util
{
	import flash.utils.*;
	public class Debug
	{
		private static var arrIndent:Array = [];
		private static var indent:String = "";

		public static function objToString(prop:*, name:String="Object"):String
		{
			Trace.initObjToString(name);
			traceObj(prop, name);
			return Trace.objToString();
		}

		// Static method to recursively trace all properties of an object and its contained objects, 
		// sorted on property name, per object, and display them graphically in a tree structure .
		public static function traceObj(prop:*, name:String="Object", last:Boolean=false):void
		{
		

				/*var tail:String = "── ";
				var riser:String = "├";
				var spaces:String = "	";
				var endriser:String = "└";
				*/
				var tail:String = "__ ";
				var riser:String = "|";
				var spaces:String = "   ";

				switch( typeof(prop) )
				{
					case 'string':
						traceAndPad(name, '"'+prop+'"');
						break ;
					case 'function':
					case 'boolean':
					case 'number':
						traceAndPad(name, prop);
						break ;
					case 'object':
						Trace.doTrace(indent + name + "(Obj):");  // trace object name

						// Adjust tree structure indent
						decIndent();   // remove tail
						if (last){
							//No more properties on this object: replace last riser with space
							decIndent();
							incIndent(" ");
						}
						// add to tree structure indent for next level of object properties
						incIndent(spaces);
						incIndent(riser);
						incIndent(tail);
						// trace the objects properties
						deepObj(prop, name);
						// remove this level's indent and trace a blank line (indent only)
						// to separate nested object properties for visual clarity
						decIndent(3);
						Trace.doTrace(indent);
						// Add tail to adjusted indent for next property.
						incIndent(tail);

						break;
					default:
						traceAndPad(name, prop);

				}
			}

			// Helper methods for traceObj()
			private static function deepObj(obj:Object, name:String):void
			{
				var arr:Array = [];
				for (var o:* in obj){
					arr.push(o);
				}
				arr.sort();

				for (var i:int = 0; i< arr.length; i++){
					traceObj(obj[arr[i]], arr[i], i==arr.length-1);
				}
			}
			private static function incIndent(s:String):void
			{
				arrIndent.push(s);
				indent = arrIndent.join("");
			}
			private static function decIndent(n:int=1):void
			{
				for (var i:int = 0; i<n; i++){
					arrIndent.pop();
				}
				indent = arrIndent.join("");
			}

			private static function traceAndPad(name:String, prop:String ):void
			{
				var pad:String =".............................................";
				var p:String = pad.substr(0,21-name.length);
				Trace.doTrace (indent + name + " " + p + prop);
			}

		// Static method to trace extract and nicely format call stack info from calling method.
		public static function traceCallStack(prefix:String=""):void
		{
				var error:Error = new Error();
				if (!error) return;

				var stack:String = error.getStackTrace();
				if (!stack) return;

				var lines:Array = stack.split("\n");
				if (lines.length < 3) return;

				var arrLine:Array = lines[2].split("[");

				Trace.doTrace(prefix + " Call Stack Trace: "+ arrLine[0].split(" ")[1]);
				for (var i:int=3; i<lines.length; i++){
					arrLine = lines[i].split("[");
					var pos:String = "";
					if (arrLine.length > 1){
						var arr2:Array = arrLine[1].split("\/");
						pos = " : " + arr2[arr2.length-1].split("]")[0];
					}
					Trace.doTrace(prefix + "    >>"+ arrLine[0]+pos);
			   }
			   Trace.doTrace(prefix + " End Call Stack Trace.");
		}

		// Static method to trace the class and method name of the calling method, with optional, user supplied arguments.
		public static function trace(...args):void
		{
				if (typeof(args[0]) == "object"){
					traceObj(args[0], args.length>1?args[1]:"Object");
				}else{
					var error:Error = new Error();
					if (!error) return;

					var stack:String = error.getStackTrace();
					if (!stack) return;

					var lines:Array = stack.split("\n");
					if (lines.length < 3) return;

					var arr1:Array = lines[2].split("[");
					var arr2:Array = arr1[0].split(" ");
					if (arr2.length < 2) return;

					var arr3:Array = arr2[1].split("::");
					if (arr3.length < 2) return;

					var caller:String = arr3[1].replace("/", "::");
					if (args.length > 0){
						var str:String = caller + " :";
						for (var s:* in args){
							str += " " + args[s];
						}
						Trace.doTrace(str);
					}else{
						Trace.doTrace(caller);
					}
				}
			}
	}

}

// Internal class to allow Debug class to use the name "trace" for a static method, for more intuitive use.
internal class Trace{
	private static var startTime:Number = 0;
	private static var retStr:String = null;

	internal static function initObjToString(name:String):void
	{
		retStr = "Object : " + name + "\n\r";
	}
	
	internal static function objToString():String
	{
		var retVal:String = retStr;
		retStr = null;
		return retVal;
	}
	
	internal static function doTrace(str:String):void
	{
		var timeNow:int = 0;
		if (startTime == 0){
			startTime = new Date().time
		}else{
			timeNow = new Date().time - startTime;
		}
		var mins:int = timeNow/60000;
		var secs:int = (timeNow - mins*60000 )/1000;
		if (retStr){
			retStr += str;
			retStr += String.fromCharCode(13);
			retStr += String.fromCharCode(10);
		}else{
			// Use a prefix, with elapsed time, for filtering in debug trace viewer (eg Vizzy)
			var prefix:String = "TubeMogul [" + ((mins<10)?"0":"") + mins + ":" + ((secs<10)?"0":"") + secs + "] ";
			trace(prefix + str);
		}
	}
}