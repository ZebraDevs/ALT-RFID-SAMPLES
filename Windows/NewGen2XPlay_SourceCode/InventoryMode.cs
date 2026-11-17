using Symbol.RFID.SDK.Domain.Reader;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Symbol.RFID.SDK.ZEBRAGen2XDemoApp
{
    public partial class InventoryMode : Form
    {

        #region Form Event Handlers
        private IRfidReader reader;
        private frmMain mainForm;
        internal const int NUM_INV_PROTOCOL = 2546;
        #endregion

        public InventoryMode(IRfidReader selectedReader, frmMain mainForm)
        {
            InitializeComponent();
            this.mainForm = mainForm;
            this.reader = selectedReader;
        }

        private void button1_Click(object sender, EventArgs e)
        {
            SetInventoryProtocol();
        }

        /// <summary>
        /// Set inventory protocol
        /// </summary>
        /// <param name="protocol">Protocol type: Gen2, Gen2X, or Hybrid</param>
        private void SetInventoryProtocol()
        {
            try
            {
                Cursor.Current = Cursors.WaitCursor;
                string protocolValue = "0"; // Default to Gen2

                if (rdGen2.Checked)
                {
                    protocolValue = "0";
                }
                else if (rdGen2x.Checked)
                {
                    protocolValue = "1";
                }
                else if (rdHybrid.Checked)
                {
                    protocolValue = "2";
                }

                reader.RemoteScannerManagement.SetAttribute(NUM_INV_PROTOCOL, "B", protocolValue);
                Thread.Sleep(100);
                string protocolName = rdGen2.Checked ? "Gen2" : rdGen2x.Checked ? "Gen2X" : "Hybrid";
                BeginInvoke((MethodInvoker)delegate { mainForm.OutputText($"Inventory Protocol set to {protocolName} successfully."); });
                Cursor.Current = Cursors.Default;
            }
            catch (Exception e)
            {
                if(e.ToString().ToLower().Contains("not allowed"))
                {
                    BeginInvoke((MethodInvoker)delegate { mainForm.OutputText($"Error setting Inventory Protocol. Value not allowed."); });

                }
                else
                {
                    BeginInvoke((MethodInvoker)delegate { mainForm.OutputText($"Error setting Inventory Protocol."); });

                }

                // Reset to Gen2 on error
                rdGen2.Checked = true;
                rdGen2x.Checked = false;
                rdHybrid.Checked = false;
                Cursor.Current = Cursors.Default;
            }
        }

        private void GetInventoryProtocol()
        {
            try
            {
                RsmAttribute invProtocol = reader.RemoteScannerManagement.GetAttribute(NUM_INV_PROTOCOL);
                if (invProtocol != null)
                {
                    rdGen2.Checked = false;
                    rdGen2x.Checked = false;
                    rdHybrid.Checked = false;

                    switch (invProtocol.Value)
                    {
                        case "0":
                            rdGen2.Checked = true;
                            break;
                        case "1":
                            rdGen2x.Checked = true;
                            break;
                        case "2":
                            rdHybrid.Checked = true;
                            break;
                        default:
                            rdGen2.Checked = true;
                            break;
                    }
                }
                else
                {
                    rdGen2.Checked = true;
                    rdGen2x.Checked = false;
                    rdHybrid.Checked = false;
                }
            }
            catch (Exception e)
            {
                BeginInvoke((MethodInvoker)delegate { mainForm.OutputText($"Error getting Inventory Protocol : {e.Message}"); });
                rdGen2.Checked = true;
                rdGen2x.Checked = false;
                rdHybrid.Checked = false;
            }
        }

        private void InventoryMode_Load(object sender, EventArgs e)
        {
            GetInventoryProtocol();
        }
    }
}
