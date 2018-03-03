using System;

namespace ExcelBiblio
{
    public class CWorkbook : IDisposable
    {
        protected dynamic __workbook;
        protected CWorkbook() { }
        public CWorkbook(dynamic workbook)
        {
            this.__workbook = workbook;
        }
        ~CWorkbook()
        {
            Dispose();
        }
        public void Dispose()
        {
            if (__workbook != null)
            {
                __workbook.Close(true);
                __workbook = null;
            }
        }
        public void SaveAs(string path)
        {
            this.__workbook.SaveAs(path);
        }
        public void Save()
        {
            this.__workbook.Save();
        }
        public ProfiCreditWorksheet ActiveSheet
        {
            get { return new ProfiCreditWorksheet(this.__workbook.ActiveSheet); }
        }

        public class ProfiCreditWorksheet
        {
            protected dynamic __worksheet;
            protected ProfiCreditWorksheet() { }
            public ProfiCreditWorksheet(dynamic worksheet)
            {
                this.__worksheet = worksheet;
            }
            public object GetCells(int row, int col)
            {
                return this.__worksheet.Cells[row, col].Value;
            }
            public void SetCells(int row, int col, object val)
            {
                this.__worksheet.Cells[row, col].Value = val;
            }
            public void RowDelete(int row)
            {
                this.__worksheet.Rows(row).Delete();
            }
        }
    }
}
