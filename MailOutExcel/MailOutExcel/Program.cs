using System;
using System.Collections.Generic;
using ExcelBiblio;
using System.IO;
using MailBiblio;
using System.Text;
using System.Threading;

namespace MailOutExcel
{
    class Program
    {
        static bool isRun = false;
        static void Main(string[] args)
        {
            int day = 24 * 60 * 60 * 1000; //ежедневно
            Timer t = new Timer(Run, null, -1, day);
            t.Change(0, day);

            while (true) ;
        }

        static void Run(object param)
        {
            if (!isRun)
            {
                isRun = true;

                try
                {
                    //получаем настройки приложения
                    var sett = Properties.Settings.Default;
                    sett.Reload();

                    //элементы для сравнения с файла
                    List<Element> l_elements = new List<Element>();

                    string new_workbookfile; //куда сохраняем результат
                    bool iswritefile = false; //нужно ли что-то отправлять
                    int i_write = 0; //сколько строк было удалено

                    //формируем новый полный путь для копии файла
                    int ind = sett.FullNameFileSaveTemp.IndexOf('.');
                    string name = sett.FullNameFileSaveTemp.Substring(0, ind);
                    string expansion = sett.FullNameFileSaveTemp.Substring(ind + 1, sett.FullNameFileSaveTemp.Length - ind - 1);
                    new_workbookfile = name + "_" + DateTime.Now.ToString().Replace('.', '_').Replace(':', '_') + "." + expansion;

                    using (CExcel excel = new CExcel())
                    {
                        using (CWorkbook workbook_read = excel.OpenWorkbook(sett.FullNameFileExcel))
                        {
                            //создали копию файла
                            workbook_read.SaveAs(new_workbookfile);
                        }
                        using (CWorkbook workbook_read = excel.OpenWorkbook(sett.FullNameFileExcel))
                        {
                            using (CWorkbook workbook_write = excel.OpenWorkbook(new_workbookfile))
                            {
                                CWorkbook.ProfiCreditWorksheet worksheet_read = workbook_read.ActiveSheet;
                                CWorkbook.ProfiCreditWorksheet worksheet_write = workbook_write.ActiveSheet;

                                object valCounterparty = null; //контрагент что ежит
                                object valFinishDate = null; //срок до что лежит
                                string counterparty = null;//контрагент
                                DateTime? finishdate; //срок до к типу дата и время
                                int i = 1;//индекс строки в файле
                                bool iswrite;//нужно ли оставить в копии файла

                                DateTime tempdt = DateTime.Now.AddDays(sett.OldDay);//колько дней сдвинуть текущую дату
                                DateTime dt = new DateTime(tempdt.Year, tempdt.Month, tempdt.Day);
                                int sizecol = 0; //кол-о колонок в файле
                                object val = null;

                                //определяем кол-во анализируемых столбцов по содержимому первых ячеек каждого столбца
                                do
                                {
                                    val = worksheet_read.GetCells(1, i);
                                    i++;
                                } while (val != null);

                                sizecol = i - 2;
                                i = 2;

                                do
                                {
                                    iswrite = false; //каждый раз сбрасываем признак того, что нужно ли сохранить запись в копии файла
                                    valCounterparty = worksheet_read.GetCells(i, sett.ColumnIndexCounterparty);
                                    if (valCounterparty != null)
                                    {
                                        counterparty = valCounterparty.ToString().Trim();
                                        valFinishDate = worksheet_read.GetCells(i, sett.ColumnIndexFinishDate);
                                        finishdate = valFinishDate as DateTime?;

                                        if (finishdate != null)
                                        {
                                            tempdt = finishdate.Value;
                                            tempdt = new DateTime(tempdt.Year, tempdt.Month, tempdt.Day);

                                            if ((tempdt.Date <= dt.Date) && (tempdt.Date >= DateTime.Now)) iswrite = true;
                                        }
                                        else iswrite = true;

                                        l_elements.Add(new Element() { Counterparty = counterparty, FinishDate = finishdate, ValFinishDate = valFinishDate });

                                        if (!iswrite)
                                        {
                                            worksheet_write.RowDelete(i - i_write);

                                            i_write++;
                                        }
                                        else iswritefile = true;

                                        i++;
                                    }
                                    else break;
                                } while (valCounterparty != null);

                                if (iswritefile)
                                {
                                    workbook_write.Save();
                                }
                            }
                        }
                    }

                    //если были записи - то отправляем с вложением файла копии
                    if (iswritefile)
                    {
                        Mail.RunMailMessage(sett.MailServer, sett.MailAddressTo, sett.MailAddressFrom,
                            sett.MainSendNotEmptyBodyMess, "По документу: было выявлено всего " + (l_elements.Count - i_write).ToString() + " записей, срок жизни которых истекает через " + sett.OldDay.ToString() + " дней и меньше.\r\nПодробности во вложении." +
                            "\r\n Соощение сформировано: " + DateTime.Now.ToString(), new string[] { new_workbookfile });
                    }
                    //иначе-по настройкам либо отправляем, либо нет сообщение о том, что ничего не выявлено
                    else if (sett.IsSendEmptyBody)
                    {
                        Mail.RunMailMessage(sett.MailServer, sett.MailAddressFrom, sett.MailAddressFrom,
                            sett.MainSendEmptyBodyMess, "По документу: записи, срок жизни которых истекает через  " + sett.OldDay.ToString() + " дней и меньше, не обнаружены."
                            + "\r\n Соощение сформировано: " + DateTime.Now.ToString());
                    }

                    try
                    {
                        File.Delete(new_workbookfile);
                    }
                    catch (Exception exp)
                    {
                        Mail.RunMailMessage(sett.MailServer, sett.MailAddressFrom, sett.MailAddressFrom,
                            "Ошибка выполнения MailOutExcel по файлу", exp.Message);
                    }
                    //Mariya.Chumakova@profi-credit.ru;Aleksey.Sukharev@profi-credit.ru;Irina.Timoshenkova@profi-credit.ru"

                    //RunMailMessage(sett.MailServer, "evgeniy.gribkov@profi-credit.ru;alexander.kepman@profi-credit.ru;", "evgeniy.gribkov@profi-credit.ru", "Тестовое сообщение", "Прошу подтвердить обратным письмом, что сообщения до Вас доходят");

                    using (Stream stream = new FileStream("log.txt", FileMode.Create, FileAccess.Write))
                    {
                        using (TextWriter tw = new StreamWriter(stream, Encoding.Unicode))
                        {
                            tw.WriteLine("Все хорошо");
                            tw.Flush();
                        }
                    }
                }
                catch (Exception exp)
                {
                    using (Stream stream = new FileStream("log.txt", FileMode.Create, FileAccess.Write))
                    {
                        using (TextWriter tw = new StreamWriter(stream, Encoding.Unicode))
                        {
                            tw.WriteLine(exp.Message);
                            tw.Flush();
                        }
                    }
                }

                Console.WriteLine("Сообщение отправлено в " + DateTime.Now.ToString());

                isRun = false;
            }
        }
    }
}