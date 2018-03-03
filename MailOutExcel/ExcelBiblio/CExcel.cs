using System;

namespace ExcelBiblio
{
    public class CExcel : IDisposable
    {
        private dynamic __excel;
        public CExcel()
        {
            Type typeExcel = Type.GetTypeFromProgID("Excel.Application");
            this.__excel = Activator.CreateInstance(typeExcel);
        }
        public CWorkbook OpenWorkbook(string path)
        {
            return new CWorkbook(this.__excel.Workbooks.Open(path));
        }
        public CWorkbook CreateWorkbook()
        {
            return new CWorkbook(this.__excel.Workbooks.Add());
        }
        ~CExcel()
        {
            Dispose();
        }
        public void Dispose()
        {
            if (__excel != null)
            {
                this.__excel.Quit();
                this.__excel = null;
            }
        }
        public dynamic Workbooks
        {
            get { return this.__excel.Workbooks; }
        }
        public dynamic Excel
        {
            get { return this.__excel; }
        }
    }
}