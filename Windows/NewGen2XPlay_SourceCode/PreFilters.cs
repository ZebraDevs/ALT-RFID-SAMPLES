using Symbol.RFID.SDK.ZEBRAGen2XDemoApp.Entities;
using Symbol.RFID.SDK.Domain.Reader;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Windows.Forms;

namespace Symbol.RFID.SDK.ZEBRAGen2XDemoApp
{
    public partial class PreFilters : Form
    {
        #region Private Fields

        private frmMain mainForm = null;

        private FilterData[] ConfiguredFilters = null;
        private int filterIndex = 0;
        private const int CurrentAntennaID = 1;
        private bool isFastIDFilterSelected = false;
        private bool isTagFocusSelected = false;
        #endregion

        #region Properties

        public IRfidReader Reader { get; set; }

        public bool DeleteAllPreFilters = false;

        public bool IsFastIDFilterSelected
        {
            get { return isFastIDFilterSelected; }
            private set { isFastIDFilterSelected = value; }
        }

        public bool IsTagFocusSelected
        {
            get { return isTagFocusSelected; }
            private set { isTagFocusSelected = value; }
        }
        #endregion

        #region Constructors

        public PreFilters(frmMain mainForm)
        {
            InitializeComponent();
            this.mainForm = mainForm;
        }

        #endregion

        #region Form Event Handlers

        private void PreFilters_Load(object sender, EventArgs e)
        {
            PopulateControls();
        }

        private void btnApplyFilter_Click(object sender, EventArgs e)
        {
            SetFilters();
            this.DialogResult = DialogResult.OK;
            this.Close();
        }

        private void cmbFilters_SelectedIndexChanged(object sender, EventArgs e)
        {

            if (ConfiguredFilters[filterIndex] == null)
            {
                ConfiguredFilters[filterIndex] = new FilterData();
                ConfiguredFilters[filterIndex].Action = cmbAction.SelectedIndex;
                ConfiguredFilters[filterIndex].IsEnable = chkEnable.Checked;
                ConfiguredFilters[filterIndex].MemoryBank = cmbMemoryBank.SelectedIndex;
                ConfiguredFilters[filterIndex].OffSet = short.Parse(txtOffSet.Text.Trim());
                ConfiguredFilters[filterIndex].TagPattern = txtTagPattern.Text.Trim();
                ConfiguredFilters[filterIndex].Target = cmbTarget.SelectedIndex;
            }

            filterIndex = cmbFilters.SelectedIndex;
            if (ConfiguredFilters[filterIndex] == null)
            {
                chkEnable.Checked = false;
                cmbAction.SelectedIndex = 0;
                cmbMemoryBank.SelectedIndex = 0;
                cmbTarget.SelectedIndex = 0;
                txtTagPattern.Text = string.Empty;
                txtOffSet.Text = "0";
                return;
            }

            txtTagPattern.Text = ConfiguredFilters[filterIndex].TagPattern;
            cmbAction.SelectedIndex = ConfiguredFilters[filterIndex].Action;
            cmbMemoryBank.SelectedIndex = ConfiguredFilters[filterIndex].MemoryBank;
            cmbTarget.SelectedIndex = ConfiguredFilters[filterIndex].Target;
            txtOffSet.Text = ConfiguredFilters[filterIndex].OffSet.ToString();
            chkEnable.Checked = ConfiguredFilters[filterIndex].IsEnable;
        }

        private void HexInput_KeyPress(object sender, KeyPressEventArgs e)
        {
            DataUtility.IsHex(e);
        }

        private void NumericInput_KeyPress(object sender, KeyPressEventArgs e)
        {
            DataUtility.IsNumeric(e);
        }

        #endregion

        #region Private Methods

        private void FrmAppMain_FormClosing(object sender, FormClosingEventArgs e)
        {
            try
            {
                if (Reader != null)
                {
                    // Check configured filters before disconnecting
                    CheckConfiguredFilters();

                }
            }
            catch (Exception ex)
            {
                Debug.Print(ex.Message);
            }
        }

        /// <summary>
        /// Check configured filters for FastID and TagFocus patterns
        /// </summary>
        private void CheckConfiguredFilters()
        {
            try
            {
                if (Reader != null && Reader.IsConnected)
                {
                    var configuredFilters = Reader.PreFilters.ConfiguredFilters;

                    // Reset flags
                    IsFastIDFilterSelected = false;
                    IsTagFocusSelected = false;

                    if (configuredFilters != null && configuredFilters.Count > 0)
                    {
                        foreach (var filter in configuredFilters)
                        {
                            if (filter.MatchPattern != null)
                            {
                                string tagPattern = DataUtility.ByteArrayToHexString(filter.MatchPattern);

                                // Check for FastID pattern
                                if (tagPattern != null && tagPattern.Equals("A006F0", StringComparison.OrdinalIgnoreCase))
                                {
                                    IsFastIDFilterSelected = true;
                                }

                                // Check for TagFocus pattern
                                if (tagPattern != null && tagPattern.Equals("A00670", StringComparison.OrdinalIgnoreCase))
                                {
                                    IsTagFocusSelected = true;
                                }
                            }
                        }
                    }

                   // mainForm.OutputText($"Filter Check - FastID: {IsFastIDFilterSelected}, TagFocus: {IsTagFocusSelected}");
                }
            }
            catch (Exception ex)
            {
                //mainForm.OutputText($"Error checking configured filters: {ex.Message}");
            }
        }
        private void PopulateControls()
        {
            try
            {
                var count = Reader.Capabilities.SupportedFilters;
                ConfiguredFilters = new FilterData[count];
                if (Reader != null)
                {
                    var filters = this.Reader.PreFilters.ConfiguredFilters;
                    if(filters.Count==0)
                    {

                    }else
                    {
                        for (int i = 0; i < filters.Count; i++)
                        {
                            ConfiguredFilters[i] = new FilterData();
                            ConfiguredFilters[i].Action = (int)filters[i].Action;
                            ConfiguredFilters[i].IsEnable = true;
                            ConfiguredFilters[i].MemoryBank = (int)filters[i].MaskBank;
                            ConfiguredFilters[i].OffSet = (short)filters[i].MaskStartPos;
                            ConfiguredFilters[i].TagPattern = DataUtility.ByteArrayToHexString(filters[i].MatchPattern);
                            ConfiguredFilters[i].Target = (int)filters[i].Target;
                            ConfiguredFilters[i].antennaID = filters[i].AntennaID;
                        }
                    }
                    
                }

                cmbAction.Items.Clear();
                cmbMemoryBank.Items.Clear();
                cmbTarget.Items.Clear();
                cmbFilters.Items.Clear();
                chkEnable.Checked = false;
                cmbAction.Items.AddRange(Enum.GetNames(typeof(FILTER_ACTION)));
                cmbAction.SelectedIndex = 0;
                cmbMemoryBank.Items.AddRange(Enum.GetNames(typeof(FILTER_MASK_BANK)));
                cmbMemoryBank.SelectedIndex = 0;
                cmbTarget.Items.AddRange(Enum.GetNames(typeof(FILTER_TARGET)));
                cmbTarget.SelectedIndex = 0;

                txtOffSet.Text = "0";
                txtTagPattern.Text = string.Empty;


                for (int i = 0; i < count; i++)
                {
                    cmbFilters.Items.Add("FILTER " + (i + 1));
                }
                cmbFilters.SelectedIndex = 0;
            }
            catch (Exception ex)
            {
                mainForm.OutputText(ex.Message);
            }
        }

        /// <summary>
        /// Configure pre filter to the device.
        /// </summary>
        private void SetFilters()
        {
            try
            {
                filterIndex = cmbFilters.SelectedIndex;

                if (ConfiguredFilters[filterIndex] == null)
                    ConfiguredFilters[filterIndex] = new FilterData();

                ConfiguredFilters[filterIndex].Action = cmbAction.SelectedIndex;
                ConfiguredFilters[filterIndex].IsEnable = chkEnable.Checked;
                ConfiguredFilters[filterIndex].MemoryBank = cmbMemoryBank.SelectedIndex;
                ConfiguredFilters[filterIndex].OffSet = short.Parse(txtOffSet.Text.Trim());
                ConfiguredFilters[filterIndex].TagPattern = txtTagPattern.Text.Trim();
                ConfiguredFilters[filterIndex].Target = cmbTarget.SelectedIndex;

                List<Filter> readerFilters = new List<Filter>();
                foreach (var item in ConfiguredFilters)
                {
                    if (item == null || !item.IsEnable || string.IsNullOrEmpty(item.TagPattern))
                        continue;

                    var f = new Filter()
                    {
                        Action = (FILTER_ACTION)item.Action,
                        MaskBank = (FILTER_MASK_BANK)item.MemoryBank,
                        Target = (FILTER_TARGET)item.Target,
                        MaskStartPos = item.OffSet,
                        MatchPattern = DataUtility.HexStringToByteArray(item.TagPattern),
                        AntennaID = (ushort) CurrentAntennaID
                    };
                    readerFilters.Add(f);
                }

                this.Reader.PreFilters.ConfiguredFilters = readerFilters;
                mainForm.OutputText("Pre-filters saved.");
            }
            catch (Exception ex)
            {
                mainForm.OutputText(ex.Message);
            }
        }



        private void BtnDeleteAllFilters_Click(object sender, EventArgs e)
        {
            if (MessageBox.Show("Are you sure you want to delete all pre-filters?", "Confirmation", MessageBoxButtons.YesNo, MessageBoxIcon.Warning) == DialogResult.Yes)
            {
                try
                {
                    List<Filter> readerFilters = new List<Filter>();
                    this.Reader.PreFilters.ConfiguredFilters = readerFilters;
                    filterIndex = 0;
                    ConfiguredFilters[filterIndex] = null;
                    PopulateControls();
                    chkEnable.Checked = false;
                    cmbAction.SelectedIndex = 0;
                    cmbMemoryBank.SelectedIndex = 0;
                    cmbTarget.SelectedIndex = 0;
                    txtTagPattern.Text = string.Empty;
                    txtOffSet.Text = "0";
                    DeleteAllPreFilters = true;
                    mainForm.OutputText("All pre-filters deleted.");
                }
                catch (Exception ex)
                {
                    mainForm.OutputText(ex.Message);
                }
            }
        }

        private void BtnDeleteFilter_Click(object sender, EventArgs e)
        {
            filterIndex = cmbFilters.SelectedIndex;
            if ((filterIndex >= 0 || filterIndex < ConfiguredFilters.Length) && (ConfiguredFilters[filterIndex] != null))
            {
                chkEnable.Checked = false;
                ConfiguredFilters[filterIndex].IsEnable = false;
                SetFilters();
                PopulateControls();
                cmbFilters_SelectedIndexChanged(null, null);
            }
        }

        private void BtnSaveFilter_Click(object sender, EventArgs e)
        {
            SetFilters();
        }
        #endregion

    }
}