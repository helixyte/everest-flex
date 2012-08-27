package org.everest.flex.ui.components {
    import mx.collections.ICollectionView;
    import mx.collections.IList;
    import mx.collections.ISort;
    import mx.collections.ISortField;
    import mx.collections.Sort;
    import mx.styles.AdvancedStyleClient;

    import spark.components.Grid;
    import spark.components.gridClasses.GridColumn;
    import spark.components.gridClasses.GridSortField;
    import spark.events.GridEvent;
    import spark.events.GridSortEvent;

    /**
     *  Multi-column sortable data grid class.
     *  Extends spark data grid and override columnHeaderGroup_clickHandler function.
     *  Provide multi-column sort function when ctrl + left click on column header.
     */
    public class MultiColSortableDataGrid extends DataGrid {

        /**
         *  @private
         */
        override protected function columnHeaderGroup_clickHandler(event:GridEvent):void {
            const column:GridColumn = event.column;
            var columnIndices:Vector.<int>;

            if (!enabled || !sortableColumns || !column || !column.sortable)
                return;

            columnIndices = Vector.<int>([column.columnIndex]);

            sortByMultiColumns(columnIndices, true, event.ctrlKey);
        }



        /**
         *  Copy and modify from DataGrid::sortByColumns function.
         *  Add one more argument multiColSort, decide if continue to use old sort fields.
         *  Achieve multi-column sort function.
         */
        public function sortByMultiColumns(columnIndices:Vector.<int>,
                            isInteractive:Boolean = false , multiColSort:Boolean = false):Boolean {

            const dataProvider:ICollectionView = this.dataProvider as ICollectionView;
            if (!dataProvider)
                return false;

            var sort:ISort = dataProvider.sort;
            if (sort) {
                sort.compareFunction = null;
            } else {
                sort = new Sort();
            }
            var sortFields:Array = createSortFields(columnIndices, sort.fields, isInteractive);
            if (!sortFields)
                return false;

            var oldSortFields:Array = (dataProvider.sort) ? dataProvider.sort.fields : null;


            // implements multi-column sort function.
            if (multiColSort && oldSortFields) {
                if (columnHeaderGroup) {
                    var colSortIndices:Vector.<int> = columnHeaderGroup.visibleSortIndicatorIndices;
                    for (var j:int = colSortIndices.length - 1 ; j >= 0 ; --j) {
                        var idx:int = colSortIndices[j];
                        if (columnIndices.indexOf(idx) < 0) {
                            columnIndices.unshift(idx);
                        }
                    }
                }

                outer: for (var i:int = oldSortFields.length - 1 ; i >= 0 ; --i) {
                    var oldField:ISortField = oldSortFields[i] as ISortField;

                    for (var k:int = 0 ; k < sortFields.length ; ++k) {
                        var newField:ISortField = sortFields[k] as ISortField;

                        if (newField.name == oldField.name) {
                            continue outer;
                        }
                    }
                    sortFields.unshift(oldField);
                }
            }

            if (isInteractive) {
                if (oldSortFields)
                    oldSortFields = oldSortFields.concat();

                if (hasEventListener(GridSortEvent.SORT_CHANGING)) {
                    const changingEvent:GridSortEvent =
                        new GridSortEvent(GridSortEvent.SORT_CHANGING,
                        false, true,
                        columnIndices,
                        oldSortFields,
                        sortFields);

                    if (!dispatchEvent(changingEvent))
                        return false;

                    columnIndices = changingEvent.columnIndices;
                    if (!columnIndices)
                        return false;

                    sortFields = changingEvent.newSortFields;
                    if (!sortFields)
                        return false;
                }
            }

            sort.fields = sortFields;

            dataProvider.sort = sort;
            dataProvider.refresh();

            if (isInteractive) {
                if (hasEventListener(GridSortEvent.SORT_CHANGE)) {
                    const changeEvent:GridSortEvent =
                        new GridSortEvent(GridSortEvent.SORT_CHANGE,
                        false, true,
                        columnIndices,
                        oldSortFields, sortFields);
                    dispatchEvent(changeEvent);
                }

                if (columnHeaderGroup)
                    columnHeaderGroup.visibleSortIndicatorIndices = columnIndices;
            }

            return true;
        }


        protected function createSortFields(columnIndices:Vector.<int>,
                                    previousFields:Array, preservePrevious:Boolean):Array {
            if (columnIndices.length == 0)
            {
                return null;
            }

            var fields:Array = new Array();

            for each (var columnIndex:int in columnIndices) {
                var col:GridColumn = this.getColumnAt(columnIndex);
                if (!col)
                {
                    return null;
                }

                var dataField:String = col.dataField;

                if (dataField == null && col.labelFunction == null && col.sortCompareFunction == null)
                {
                    return null;
                }

                const isComplexDataField:Boolean = (dataField && (dataField.indexOf(".") != -1));
                var sortField:ISortField = null;
                var sortDescending:Boolean = col.sortDescending;

                sortField = findSortField(dataField, fields, isComplexDataField);

                if (!sortField && previousFields)
                {
                    sortField = findSortField(dataField, previousFields, isComplexDataField);
                }else{
                    preservePrevious = false;
                }

                if (sortField)
                {
                    sortDescending = !sortField.descending;
                }

                if (!sortField || preservePrevious)
                {
                    sortField = col.sortField;
                }

                col.sortDescending = sortDescending;
                sortField.descending = sortDescending;
                fields.push(sortField);
            }

            return fields;
        }


        private function getColumnAt(columnIndex:int):GridColumn {
            const grid:Grid = grid;
            if (!grid || !grid.columns)
            {
                return null;
            }
            const columns:IList = grid.columns;
            return ((columnIndex >= 0) && (columnIndex < columns.length)) ? columns.getItemAt(columnIndex) as GridColumn : null;
        }


        private static function findSortField(dataField:String, fields:Array, isComplexDataField:Boolean):ISortField {
            if (dataField == null){
                return null;
            }
            for each (var field:ISortField in fields) {
                var name:String = field.name;
                if (isComplexDataField && (field is GridSortField))
                {
                    name = GridSortField(field).dataFieldPath;
                }
                if (name == dataField)
                {
                    return field;
                }
            }
            return null;
        }
    }
}
