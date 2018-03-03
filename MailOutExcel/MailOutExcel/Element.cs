using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MailOutExcel
{
    internal class Element
    {
        string __counterparty;
        DateTime? __finishdate;
        object __valfinishdate;
        public Element()
        { }
        public string Counterparty
        {
            get { return this.__counterparty; }
            set { this.__counterparty = value; }
        }
        public DateTime? FinishDate
        {
            get { return this.__finishdate; }
            set { this.__finishdate = value; }
        }
        public object ValFinishDate
        {
            get { return this.__valfinishdate; }
            set { this.__valfinishdate = value; }
        }
        public bool IsCorrect {
            get { return (this.__finishdate != null); }
        }
    }
}
