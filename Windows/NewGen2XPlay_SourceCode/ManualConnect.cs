using Symbol.RFID.SDK.Domain.Reader;
using System;
using System.Text.RegularExpressions;
using System.Windows.Forms;

namespace Symbol.RFID.SDK.ZEBRAGen2XDemoApp
{
    public partial class ManualConnect : Form
    {
        #region Private Fields

        private const string DefaultPort = "5086";

        private frmMain mainForm = null;
        private Regex regexCOM = new Regex(@"\b\d{1,255}\b");

        private int portNumber = 0;

        #endregion

        #region Properties

        public IRfidReader Reader { get; set; }

        #endregion

        #region Constructors

        public ManualConnect(frmMain mainForm)
        {
            InitializeComponent();
            this.mainForm = mainForm;

            txtPort.Text = DefaultPort;
        }
        #endregion

        #region Form Event Handlers
        private void ManualConnect_Load(object sender, EventArgs e)
        {
            cmbReaderType.SelectedIndex = 0;
        }

        private void rdoCom_Click(object sender, EventArgs e)
        {
            if (rdoCom.Checked)
            {
                lblIP.Text = "COM Port";
                txtPort.Enabled = false;
            }
        }

        private void btnConnect_Click(object sender, EventArgs e)
        {
            Connect();
        }
        #endregion

        #region Private Methods

        private void Connect()
        {
            try
            {
                MatchCollection collection;

                if (string.IsNullOrEmpty(txtIpCom.Text))
                {
                    MessageBox.Show("COM port should not be empty.");
                    return;
                }

                collection = regexCOM.Matches(txtIpCom.Text);
                if (collection.Count == 0)
                {
                    MessageBox.Show("Invalid COM port.");
                    return;
                }


                if (cmbReaderType.SelectedItem.ToString() == "RFD")
                    mainForm.ReaderInfo = new ReaderInfo("USB Serial Device (COM" + txtIpCom.Text.Trim() + ")", "COM" + txtIpCom.Text.Trim(), "COM" + txtIpCom.Text.Trim(), ReaderStatus.NotConnected, ReaderCommunicationMode.USB);
                else if (cmbReaderType.SelectedItem.ToString() == "RFD")
                    mainForm.ReaderInfo = new ReaderInfo("USB Serial Device (COM" + txtIpCom.Text.Trim() + ")", "COM" + txtIpCom.Text.Trim(), "COM" + txtIpCom.Text.Trim(), ReaderStatus.NotConnected, ReaderCommunicationMode.USB, ReaderType.SRV);
                else
                    mainForm.ReaderInfo = new ReaderInfo("USB Serial Device (COM" + txtIpCom.Text.Trim() + ")", "COM" + txtIpCom.Text.Trim(), "COM" + txtIpCom.Text.Trim(), ReaderStatus.NotConnected, ReaderCommunicationMode.USB, ReaderType.FXP);

                Close();
            }
            catch (Exception e1)
            {
                mainForm.OutputText($"Connect failed : {e1.Message}");
            }
        }
        #endregion
    }
}

