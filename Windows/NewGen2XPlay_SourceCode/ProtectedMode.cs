using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Windows.Forms;
using Symbol.RFID.SDK.Domain.Reader;

namespace Symbol.RFID.SDK.ZEBRAGen2XDemoApp
{
    public partial class ProtectedMode : Form
    {
        public IRfidReader Reader { get; set; }

        private frmMain mainForm = null;

        private const int AntennaID = 1;

        #region Constructors

        public ProtectedMode(frmMain mainForm)
        {
            InitializeComponent();
            this.mainForm = mainForm;
        }

        #endregion
        private void ProtectedMode_Load(object sender, EventArgs e)
        {
            cboProtectMode.Items.Add("Protect");
            cboProtectMode.Items.Add("Unprotect");
            cboProtectMode.Items.Add("Get Password");
            cboProtectMode.Items.Add("Set Password");
            cboProtectMode.Items.Add("Enable Inventory of Protected Tags");
            cboProtectMode.Items.Add("Clear Protected Mode Configuration");
            cboProtectMode.SelectedIndex = 0;
            List < Filter > readerFilters = new List<Filter>();
            this.Reader.PreFilters.ConfiguredFilters = readerFilters;

            if(Reader.ReaderType==ReaderType.RFD)
            {
                var singulationControl = new SingulationControl();
                singulationControl.Session = SESSION.SESSION_S0;
                singulationControl.State = STATE.AB_FLIP;
                singulationControl.SLFlag = SL_FLAG.ALL;
                singulationControl.TagPopulation = 30;
                RFIDLibraryUtility.SetSingulation(Reader, AntennaID-1, singulationControl);
            }
            else
            {
                for (int i = 1; i <= Reader.Capabilities.NumAntennaSupported; i++)
                {
                    try
                    {
                        var singulationControl = new SingulationControl();
                        singulationControl.Session = SESSION.SESSION_S0;
                        singulationControl.State = STATE.AB_FLIP;
                        singulationControl.SLFlag = SL_FLAG.ALL;
                        singulationControl.TagPopulation = 30;
                        RFIDLibraryUtility.SetSingulation(Reader, i - 1, singulationControl);
                    }
                    catch { }
                    
                }
            }
        }

        private void btnPerformOperation_Click(object sender, EventArgs e)
        {
            if (cboProtectMode.SelectedIndex==0)
            {
                TagProtect();
            }
            else if (cboProtectMode.SelectedIndex == 1)
            {
                TagUnprotect();
            }
            else if (cboProtectMode.SelectedIndex == 2)
            {
                ReadTagDataPwd();
            }
            else if (cboProtectMode.SelectedIndex == 3)
            {
                WriteTagDataPwd();
            }
            else if (cboProtectMode.SelectedIndex == 4)
            {
                TagEnableVisibility();  
            }
            else if (cboProtectMode.SelectedIndex == 5)
            {
                TagDisableVisibility();
            }
        }

        private void TagProtect()
        {
            try
            {
                Cursor.Current = Cursors.WaitCursor;
                if (string.IsNullOrEmpty(txtProtectTagPattern.Text))
                    throw new Exception("Impinj tag pattern field should not be empty.");

                
                    try
                    {
                        RFIDLibraryUtility.ImpinjProtectTag(Reader, txtProtectTagPattern.Text, txtProtectPassword.Text, AntennaID);
                        BeginInvoke((MethodInvoker)delegate
                        {
                            mainForm.OutputText($"Impinj - Tag Protected : {txtProtectTagPattern.Text}");
                            Cursor.Current = Cursors.Default;
                        });

                    }
                    catch (Exception ex)
                    {
                        BeginInvoke((MethodInvoker)delegate { mainForm.OutputText(ex.Message); });
                    }

              
            }
            catch (Exception ex)
            {
                mainForm.OutputText(ex.Message);
                Cursor.Current = Cursors.Default;
            }
            Cursor.Current = Cursors.Default;
        }

        private void TagUnprotect()
        {
            try
            {
                Cursor.Current = Cursors.WaitCursor;
                if (string.IsNullOrEmpty(txtProtectTagPattern.Text))
                    throw new Exception("Impinj tag pattern field should not be empty.");

               
                    try
                    {
                        RFIDLibraryUtility.ImpinjUnprotectTag(Reader, txtProtectTagPattern.Text, txtProtectPassword.Text, AntennaID);
                        BeginInvoke((MethodInvoker)delegate
                        {
                            mainForm.OutputText($"Impinj - Tag Unprotected : {txtProtectTagPattern.Text}");
                            Cursor.Current = Cursors.Default;
                        });
                    }
                    catch (Exception ex)
                    {
                        BeginInvoke((MethodInvoker)delegate { mainForm.OutputText(ex.Message); });
                    }
              
            }
            catch (Exception ex)
            {
                mainForm.OutputText(ex.Message);
                Cursor.Current = Cursors.Default;
            }
            Cursor.Current = Cursors.Default;
        }

        private void ReadTagDataPwd()
        {
            try
            {
                if (string.IsNullOrEmpty(txtProtectTagPattern.Text))
                {
                    mainForm.OutputText("Tag Pattern filed should not be empty.");
                    return;
                }

                Cursor.Current = Cursors.WaitCursor;

                Reader.AccessOperations.TagRead.MemoryBank = MEMORY_BANK.RESV;
                Reader.AccessOperations.TagRead.Length = 2;
                Reader.AccessOperations.TagRead.Offset = 2;
                Reader.AccessOperations.TagRead.Password = "00";
                Reader.AccessOperations.TagRead.TagPattern = DataUtility.HexStringToByteArray(txtProtectTagPattern.Text);

                
                    try
                    {
                        Reader.AccessOperations.TagRead.Read();
                        BeginInvoke((MethodInvoker)delegate
                        {
                            txtProtectPassword.Text = DataUtility.ByteArrayToHexString(Reader.AccessOperations.TagRead.TagData);
                            Cursor.Current = Cursors.Default;
                        });
                    }
                    catch
                    {
                        BeginInvoke((MethodInvoker)delegate { mainForm.OutputText("Failed to get password"); });
                    }

                    BeginInvoke((MethodInvoker)delegate { Cursor.Current = Cursors.Default; });
               
            }
            catch
            {
                BeginInvoke((MethodInvoker)delegate { mainForm.OutputText("Failed to get password"); });
                Cursor.Current = Cursors.Default;
            }
            Cursor.Current = Cursors.Default;
        }

        private void WriteTagDataPwd()
        {
            try
            {
                if (string.IsNullOrEmpty(txtProtectTagPattern.Text))
                {
                    mainForm.OutputText("Tag Pattern filed should not be empty.");
                    return;
                }

                if (string.IsNullOrEmpty(txtProtectPassword.Text))
                {
                    mainForm.OutputText("Tag password filed should not be empty.");
                    return;
                }

                Reader.AccessOperations.TagWrite.MemoryBank = MEMORY_BANK.RESV;

                Reader.AccessOperations.TagWrite.Offset = 2;
                Reader.AccessOperations.TagWrite.Password = "00";
                Reader.AccessOperations.TagWrite.TagPattern = DataUtility.HexStringToByteArray(txtProtectTagPattern.Text);
                var data = DataUtility.HexStringToByteArray(txtProtectPassword.Text);
                try
                {
                    Reader.AccessOperations.TagWrite.TagData = data;
                    Cursor.Current = Cursors.WaitCursor;
                    Reader.AccessOperations.TagWrite.Write();
                    BeginInvoke((MethodInvoker)delegate { mainForm.OutputText("Set password successfully."); Cursor.Current = Cursors.Default; });
                }
                catch
                {
                    BeginInvoke((MethodInvoker)delegate { mainForm.OutputText("Failed to set password"); });
                    Cursor.Current = Cursors.Default;
                }

            }
            catch
            {
                BeginInvoke((MethodInvoker)delegate { mainForm.OutputText("Failed to set password"); });
                
            }

            Cursor.Current = Cursors.Default;
        }

        private void TagEnableVisibility()
        {
            try
            {
                Cursor.Current = Cursors.WaitCursor;

                if (string.IsNullOrEmpty(txtProtectPassword.Text))
                    throw new Exception("Impinj tag password field should not be empty.");

               
                    try
                    {
                        RFIDLibraryUtility.ImpinjTagVisibility(Reader, txtProtectPassword.Text,true, AntennaID);
                        BeginInvoke((MethodInvoker)delegate
                        {
                            mainForm.OutputText($"Impinj - Enabled Inventory of Protected Tags.");
                            Cursor.Current = Cursors.Default;
                        });

                    }
                    catch (Exception ex)
                    {
                        BeginInvoke((MethodInvoker)delegate { mainForm.OutputText(ex.Message); });
                    }

            }
            catch (Exception ex)
            {
                mainForm.OutputText(ex.Message);
                
            }
            Cursor.Current = Cursors.Default;
        }

        private void TagDisableVisibility()
        {
            try
            {
                Cursor.Current = Cursors.WaitCursor;

                if (string.IsNullOrEmpty(txtProtectPassword.Text))
                    throw new Exception("Impinj tag password field should not be empty.");

                    try
                    {
                        RFIDLibraryUtility.ImpinjTagVisibility(Reader, txtProtectPassword.Text, false, AntennaID);
                        BeginInvoke((MethodInvoker)delegate
                        {
                            mainForm.OutputText($"Impinj - Cleared Protected Mode Configuration.");
                            Cursor.Current = Cursors.Default;
                        });

                    }
                    catch (Exception ex)
                    {
                        BeginInvoke((MethodInvoker)delegate { mainForm.OutputText(ex.Message); });
                    }

            }
            catch (Exception ex)
            {
                mainForm.OutputText(ex.Message); 
            }
            Cursor.Current = Cursors.Default;
        }

        private void cboProtectMode_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (cboProtectMode.SelectedIndex == 0)
            {
               label1.Visible= txtProtectTagPattern.Visible = true;
            }
            else if (cboProtectMode.SelectedIndex == 1)
            {
                label1.Visible = txtProtectTagPattern.Visible = true;
            }
            else if (cboProtectMode.SelectedIndex == 2)
            {
                label1.Visible = txtProtectTagPattern.Visible = true;
            }
            else if (cboProtectMode.SelectedIndex == 3)
            {
                label1.Visible = txtProtectTagPattern.Visible = true;
            }
            else if (cboProtectMode.SelectedIndex == 4)
            {
                label1.Visible = txtProtectTagPattern.Visible = false;
            }
            else if (cboProtectMode.SelectedIndex == 5)
            {
                label1.Visible = txtProtectTagPattern.Visible = false;  
            }
        }

        private void txtProtectPassword_KeyPress(object sender, KeyPressEventArgs e)
        {
            // If the character is NOT a control character (like Backspace) and NOT a hex digit
            if (!char.IsControl(e.KeyChar) && !Uri.IsHexDigit(e.KeyChar))
            {
                e.Handled = true;
            }
        }

        private void txtProtectPassword_TextChanged(object sender, EventArgs e)
        {
            // Remove any non-hex characters that may have been pasted
            string text = txtProtectPassword.Text;
            string filtered = string.Empty;
            foreach (char c in text)
            {
                if (Uri.IsHexDigit(c))
                    filtered += c;
            }

            if (filtered != text)
            {
                int selectionStart = txtProtectPassword.SelectionStart - (text.Length - filtered.Length);
                txtProtectPassword.Text = filtered;
                txtProtectPassword.SelectionStart = Math.Max(0, selectionStart);
            }
        }
    }
}
