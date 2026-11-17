using Symbol.RFID.SDK.Domain.Reader;
using System;
using System.Collections.Generic;
using System.Windows.Forms;


namespace Symbol.RFID.SDK.ZEBRAGen2XDemoApp
{
    public partial class TagQuieting : Form
    {
        /// <summary>
        /// Tag Quiet Mask Values names lookup
        /// </summary>
        public enum TagQuietMaskValue
        {
            /// <summary>
            /// S0B
            /// </summary>
            S0B = 0,
            /// <summary>
            /// S2B
            /// </summary>
            S2B = 1,
            /// <summary>
            /// S3B
            /// </summary>
            S3B = 2,
            /// <summary>
            /// SL Assert
            /// </summary>
            SL_ASSERT = 3,
            /// <summary>
            /// S0A
            /// </summary>
            S0A = 4,
            /// <summary>
            /// S2A
            /// </summary>
            S2A = 5,
            /// <summary>
            /// S3A
            /// </summary>
            S3A = 6,
            /// <summary>
            /// SL Deassert
            /// </summary>
            SL_DEASSERT = 7
        }

        public IRfidReader Reader { get; set; }

        public bool DeleteAllPreFilters = false;

        private frmMain mainForm = null;

        #region Constructors
       
        public TagQuieting(frmMain mainForm)
        {
            InitializeComponent();
            this.mainForm = mainForm;
        }
        #endregion
        private void TagQuieting_Load(object sender, EventArgs e)
        {
            cboMask1.Items.AddRange(Enum.GetNames(typeof(TagQuietMaskValue)));
            cboMask2.Items.AddRange(Enum.GetNames(typeof(TagQuietMaskValue)));
            cboMask3.Items.AddRange(Enum.GetNames(typeof(TagQuietMaskValue)));

            cmbAction.Items.AddRange(Enum.GetNames(typeof(FILTER_ACTION)));
            cmbAction.SelectedIndex = 0;
            cmbTarget.Items.AddRange(Enum.GetNames(typeof(FILTER_TARGET)));
            cmbTarget.SelectedIndex = 0;

            cmbAction.SelectedIndex = (int) mainForm.TagQuietAction;
            cmbTarget.SelectedIndex = (int) mainForm.TagQuietTarget; 

            if (mainForm.TagQuietMasks.Count >= 1)
            {
                cboMask1.SelectedIndex = (int)mainForm.TagQuietMasks[0];
            }
            if (mainForm.TagQuietMasks.Count >= 2)
            {
                cboMask2.SelectedIndex = (int)mainForm.TagQuietMasks[1];
            }
            if (mainForm.TagQuietMasks.Count >= 3)
            {
                cboMask3.SelectedIndex = (int)mainForm.TagQuietMasks[2];
            }
        }

        private void BtnDeleteAllFilters_Click(object sender, EventArgs e)
        {
            try
            {
                if (MessageBox.Show("Are you sure you want to delete all pre-filters?", "Confirmation", MessageBoxButtons.YesNo, MessageBoxIcon.Warning) == DialogResult.Yes)
                {
                    List<Filter> readerFilters = new List<Filter>();
                    this.Reader.PreFilters.ConfiguredFilters = readerFilters;
                    DeleteAllPreFilters = true;
                    mainForm.OutputText("All pre-filters deleted.");
                }
            }
            catch (Exception ex)
            {
                mainForm.OutputText("Error deleting filters: " + ex.Message);
            }
        }

        private void BtnSaveFilter_Click(object sender, EventArgs e)
        {
            try
            {
                mainForm.TagQuietAction = (FILTER_ACTION)cmbAction.SelectedIndex;
                mainForm.TagQuietTarget = (FILTER_TARGET)cmbTarget.SelectedIndex;

                mainForm.TagQuietMasks.Clear();
                if (cboMask1.SelectedIndex != -1)
                {
                    mainForm.TagQuietMasks.Add((TagQuietMaskValue)cboMask1.SelectedIndex);
                }
                if (cboMask2.SelectedIndex != -1)
                {
                    mainForm.TagQuietMasks.Add((TagQuietMaskValue)cboMask2.SelectedIndex);
                }
                if (cboMask3.SelectedIndex != -1)
                {
                    mainForm.TagQuietMasks.Add((TagQuietMaskValue)cboMask3.SelectedIndex);
                }

                List<TagQuietMask> TagQuietMasksList = new List<TagQuietMask>();
                foreach (TagQuietMaskValue mask in mainForm.TagQuietMasks)
                {
                    TagQuietMasksList.Add((TagQuietMask)Enum.Parse(typeof(TagQuietMask), Enum.GetName(typeof(TagQuietMaskValue), mask)));
                }
                RFIDLibraryUtility.ImpinjTagQuiet(Reader, TagQuietMasksList.ToArray(), mainForm.TagQuietTarget, mainForm.TagQuietAction, 1);
                mainForm.OutputText("Filter mask saved successfully.");
            }
            catch (Exception ex)
            {
                mainForm.OutputText("Error saving filter mask: " + ex.Message);
            }
        }
    }
}
