package org.everest.flex.utils
{
	public class LabelUtils
	{
		public function LabelUtils()
		{
		}
		
		public static function makeListLabelFunction(memberClass:Class, field:String):*
		{
			var f:Function = function(item:Object):String
			{
				var mbCls:* = arguments.callee.memberClass;
				if (item is mbCls)
				{
					return item[arguments.callee.field];
				}
				return ""; 
			}
			var _f:Object = f;
			_f.memberClass = memberClass;
			_f.field = field;
			return _f;			
		}
		
		public static function makeGridLabelFunction(memberClass:Class, field:String):*
		{
			var f:Function = function(item:Object, column:*):String
			{
				var mbCls:* = arguments.callee.memberClass; 
				var mb:* = mbCls(item[column.dataField]);
				if (mb != null)
				{
					return mb[arguments.callee.field];
				}
				return ""; 
			}
			var _f:Object = f;
			_f.memberClass = memberClass;
			_f.field = field;
			return _f;
		}
		
	}
}