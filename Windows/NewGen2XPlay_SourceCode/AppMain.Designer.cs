using System.ComponentModel;
using System.Windows.Forms;

namespace Symbol.RFID.SDK.ZEBRAGen2XDemoApp
{
    partial class frmMain
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.Windows.Forms.TabControl tabContainer;
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmMain));
            this.tabInventory = new System.Windows.Forms.TabPage();
            this.panel1 = new System.Windows.Forms.Panel();
            this.lblTotalReadCount = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.lbluniquetgs10s = new System.Windows.Forms.Label();
            this.lblReadRatew = new System.Windows.Forms.Label();
            this.lblReadRate = new System.Windows.Forms.Label();
            this.lblGreen = new System.Windows.Forms.Label();
            this.lblGray = new System.Windows.Forms.Label();
            this.lblW = new System.Windows.Forms.Label();
            this.lblY = new System.Windows.Forms.Label();
            this.lblUtgs = new System.Windows.Forms.Label();
            this.lblunqtags = new System.Windows.Forms.Label();
            this.lblTime = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.txtStopTimer = new System.Windows.Forms.TextBox();
            this.label1 = new System.Windows.Forms.Label();
            this.btnUnquiet = new System.Windows.Forms.Button();
            this.txtQuietTime = new System.Windows.Forms.TextBox();
            this.chkSelectAll = new System.Windows.Forms.CheckBox();
            this.lblQuiet = new System.Windows.Forms.Label();
            this.chkEnableFastID = new System.Windows.Forms.CheckBox();
            this.chkTagFocus = new System.Windows.Forms.CheckBox();
            this.btnSetTagQuiet = new System.Windows.Forms.Button();
            this.grdTags = new System.Windows.Forms.DataGridView();
            this.comboBoxReaders = new System.Windows.Forms.ComboBox();
            this.lblReaders = new System.Windows.Forms.Label();
            this.lblLog = new System.Windows.Forms.Label();
            this.btnInventoryStart = new System.Windows.Forms.Button();
            this.btnPurgeTags = new System.Windows.Forms.Button();
            this.btnInventoryStop = new System.Windows.Forms.Button();
            this.btnManualConnect = new System.Windows.Forms.Button();
            this.btnConnectDisconnect = new System.Windows.Forms.Button();
            this.btnPairNew = new System.Windows.Forms.Button();
            this.menuStrip1 = new System.Windows.Forms.MenuStrip();
            this.settingsMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.singulationMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.preFilters = new System.Windows.Forms.ToolStripMenuItem();
            this.customTagQuietingToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.protectedModeToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.InventoryProtocolToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.helpMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.aboutToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.txtOutput = new System.Windows.Forms.TextBox();
            this.lblStatusMsg = new System.Windows.Forms.Label();
            tabContainer = new System.Windows.Forms.TabControl();
            tabContainer.SuspendLayout();
            this.tabInventory.SuspendLayout();
            this.panel1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.grdTags)).BeginInit();
            this.menuStrip1.SuspendLayout();
            this.SuspendLayout();
            // 
            // tabContainer
            // 
            tabContainer.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            tabContainer.Controls.Add(this.tabInventory);
            tabContainer.Font = new System.Drawing.Font("Segoe UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            tabContainer.Location = new System.Drawing.Point(17, 91);
            tabContainer.Name = "tabContainer";
            tabContainer.SelectedIndex = 0;
            tabContainer.Size = new System.Drawing.Size(1107, 559);
            tabContainer.TabIndex = 45;
            // 
            // tabInventory
            // 
            this.tabInventory.BackColor = System.Drawing.SystemColors.ControlLightLight;
            this.tabInventory.Controls.Add(this.panel1);
            this.tabInventory.Controls.Add(this.txtStopTimer);
            this.tabInventory.Controls.Add(this.label1);
            this.tabInventory.Controls.Add(this.btnUnquiet);
            this.tabInventory.Controls.Add(this.txtQuietTime);
            this.tabInventory.Controls.Add(this.chkSelectAll);
            this.tabInventory.Controls.Add(this.lblQuiet);
            this.tabInventory.Controls.Add(this.chkEnableFastID);
            this.tabInventory.Controls.Add(this.chkTagFocus);
            this.tabInventory.Controls.Add(this.btnSetTagQuiet);
            this.tabInventory.Controls.Add(this.grdTags);
            this.tabInventory.Location = new System.Drawing.Point(4, 24);
            this.tabInventory.Name = "tabInventory";
            this.tabInventory.Padding = new System.Windows.Forms.Padding(3, 3, 3, 3);
            this.tabInventory.Size = new System.Drawing.Size(1099, 531);
            this.tabInventory.TabIndex = 0;
            this.tabInventory.Text = "Inventory";
            // 
            // panel1
            // 
            this.panel1.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.panel1.Controls.Add(this.lblTotalReadCount);
            this.panel1.Controls.Add(this.label4);
            this.panel1.Controls.Add(this.label3);
            this.panel1.Controls.Add(this.lbluniquetgs10s);
            this.panel1.Controls.Add(this.lblReadRatew);
            this.panel1.Controls.Add(this.lblReadRate);
            this.panel1.Controls.Add(this.lblGreen);
            this.panel1.Controls.Add(this.lblGray);
            this.panel1.Controls.Add(this.lblW);
            this.panel1.Controls.Add(this.lblY);
            this.panel1.Controls.Add(this.lblUtgs);
            this.panel1.Controls.Add(this.lblunqtags);
            this.panel1.Controls.Add(this.lblTime);
            this.panel1.Controls.Add(this.label2);
            this.panel1.Location = new System.Drawing.Point(709, 5);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(384, 81);
            this.panel1.TabIndex = 63;
            // 
            // lblTotalReadCount
            // 
            this.lblTotalReadCount.AutoSize = true;
            this.lblTotalReadCount.Font = new System.Drawing.Font("Segoe UI", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblTotalReadCount.Location = new System.Drawing.Point(85, 8);
            this.lblTotalReadCount.Name = "lblTotalReadCount";
            this.lblTotalReadCount.Size = new System.Drawing.Size(14, 15);
            this.lblTotalReadCount.TabIndex = 68;
            this.lblTotalReadCount.Text = "0";
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(4, 8);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(70, 15);
            this.label4.TabIndex = 67;
            this.label4.Text = "Total Reads:";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(139, 29);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(153, 15);
            this.label3.TabIndex = 65;
            this.label3.Text = "New Unique Tags Every 10s:";
            // 
            // lbluniquetgs10s
            // 
            this.lbluniquetgs10s.AutoSize = true;
            this.lbluniquetgs10s.Font = new System.Drawing.Font("Segoe UI", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lbluniquetgs10s.Location = new System.Drawing.Point(298, 29);
            this.lbluniquetgs10s.Name = "lbluniquetgs10s";
            this.lbluniquetgs10s.Size = new System.Drawing.Size(14, 15);
            this.lbluniquetgs10s.TabIndex = 66;
            this.lbluniquetgs10s.Text = "0";
            // 
            // lblReadRatew
            // 
            this.lblReadRatew.AutoSize = true;
            this.lblReadRatew.Location = new System.Drawing.Point(139, 7);
            this.lblReadRatew.Name = "lblReadRatew";
            this.lblReadRatew.Size = new System.Drawing.Size(62, 15);
            this.lblReadRatew.TabIndex = 63;
            this.lblReadRatew.Text = "Read Rate:";
            // 
            // lblReadRate
            // 
            this.lblReadRate.AutoSize = true;
            this.lblReadRate.Font = new System.Drawing.Font("Segoe UI", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblReadRate.Location = new System.Drawing.Point(207, 8);
            this.lblReadRate.Name = "lblReadRate";
            this.lblReadRate.Size = new System.Drawing.Size(14, 15);
            this.lblReadRate.TabIndex = 64;
            this.lblReadRate.Text = "0";
            // 
            // lblGreen
            // 
            this.lblGreen.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(192)))), ((int)(((byte)(0)))));
            this.lblGreen.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.lblGreen.Font = new System.Drawing.Font("Segoe UI", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblGreen.Location = new System.Drawing.Point(100, 51);
            this.lblGreen.Name = "lblGreen";
            this.lblGreen.Size = new System.Drawing.Size(90, 22);
            this.lblGreen.TabIndex = 3;
            this.lblGreen.Text = "0";
            this.lblGreen.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblGray
            // 
            this.lblGray.BackColor = System.Drawing.Color.Silver;
            this.lblGray.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.lblGray.Font = new System.Drawing.Font("Segoe UI", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblGray.Location = new System.Drawing.Point(193, 51);
            this.lblGray.Name = "lblGray";
            this.lblGray.Size = new System.Drawing.Size(90, 22);
            this.lblGray.TabIndex = 2;
            this.lblGray.Text = "0";
            this.lblGray.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblW
            // 
            this.lblW.BackColor = System.Drawing.Color.White;
            this.lblW.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.lblW.Font = new System.Drawing.Font("Segoe UI", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblW.Location = new System.Drawing.Point(286, 51);
            this.lblW.Name = "lblW";
            this.lblW.Size = new System.Drawing.Size(90, 22);
            this.lblW.TabIndex = 1;
            this.lblW.Text = "0";
            this.lblW.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblY
            // 
            this.lblY.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(255)))), ((int)(((byte)(128)))));
            this.lblY.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.lblY.Font = new System.Drawing.Font("Segoe UI", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblY.Location = new System.Drawing.Point(7, 51);
            this.lblY.Name = "lblY";
            this.lblY.Size = new System.Drawing.Size(90, 22);
            this.lblY.TabIndex = 0;
            this.lblY.Text = "0";
            this.lblY.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblUtgs
            // 
            this.lblUtgs.AutoSize = true;
            this.lblUtgs.Location = new System.Drawing.Point(4, 29);
            this.lblUtgs.Name = "lblUtgs";
            this.lblUtgs.Size = new System.Drawing.Size(75, 15);
            this.lblUtgs.TabIndex = 59;
            this.lblUtgs.Text = "Unique Tags:";
            // 
            // lblunqtags
            // 
            this.lblunqtags.AutoSize = true;
            this.lblunqtags.Font = new System.Drawing.Font("Segoe UI", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblunqtags.Location = new System.Drawing.Point(85, 29);
            this.lblunqtags.Name = "lblunqtags";
            this.lblunqtags.Size = new System.Drawing.Size(14, 15);
            this.lblunqtags.TabIndex = 60;
            this.lblunqtags.Text = "0";
            // 
            // lblTime
            // 
            this.lblTime.AutoSize = true;
            this.lblTime.Font = new System.Drawing.Font("Segoe UI", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblTime.Location = new System.Drawing.Point(318, 5);
            this.lblTime.Name = "lblTime";
            this.lblTime.Size = new System.Drawing.Size(55, 15);
            this.lblTime.TabIndex = 62;
            this.lblTime.Text = "00:00:00";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(271, 5);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(41, 15);
            this.label2.TabIndex = 61;
            this.label2.Text = "Timer:";
            // 
            // txtStopTimer
            // 
            this.txtStopTimer.Location = new System.Drawing.Point(137, 41);
            this.txtStopTimer.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.txtStopTimer.Name = "txtStopTimer";
            this.txtStopTimer.Size = new System.Drawing.Size(69, 23);
            this.txtStopTimer.TabIndex = 62;
            this.txtStopTimer.TextChanged += new System.EventHandler(this.NumericTextBox_TextChanged);
            this.txtStopTimer.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.txtQuietTime_KeyPress);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(12, 44);
            this.label1.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(121, 15);
            this.label1.TabIndex = 61;
            this.label1.Text = "Inventory Stop Timer:";
            // 
            // btnUnquiet
            // 
            this.btnUnquiet.BackColor = System.Drawing.SystemColors.ButtonHighlight;
            this.btnUnquiet.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("btnUnquiet.BackgroundImage")));
            this.btnUnquiet.FlatAppearance.BorderColor = System.Drawing.Color.Black;
            this.btnUnquiet.FlatAppearance.BorderSize = 0;
            this.btnUnquiet.FlatAppearance.MouseDownBackColor = System.Drawing.Color.Transparent;
            this.btnUnquiet.FlatAppearance.MouseOverBackColor = System.Drawing.Color.Transparent;
            this.btnUnquiet.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnUnquiet.Font = new System.Drawing.Font("Microsoft Sans Serif", 7.8F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnUnquiet.ForeColor = System.Drawing.Color.White;
            this.btnUnquiet.Location = new System.Drawing.Point(300, 8);
            this.btnUnquiet.Name = "btnUnquiet";
            this.btnUnquiet.Size = new System.Drawing.Size(79, 28);
            this.btnUnquiet.TabIndex = 58;
            this.btnUnquiet.Text = "UNQUIET";
            this.btnUnquiet.UseVisualStyleBackColor = false;
            this.btnUnquiet.Click += new System.EventHandler(this.button1_Click);
            // 
            // txtQuietTime
            // 
            this.txtQuietTime.Location = new System.Drawing.Point(84, 11);
            this.txtQuietTime.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.txtQuietTime.Name = "txtQuietTime";
            this.txtQuietTime.Size = new System.Drawing.Size(122, 23);
            this.txtQuietTime.TabIndex = 56;
            this.txtQuietTime.Text = "2";
            this.txtQuietTime.TextChanged += new System.EventHandler(this.NumericTextBox_TextChanged);
            this.txtQuietTime.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.txtQuietTime_KeyPress);
            // 
            // chkSelectAll
            // 
            this.chkSelectAll.AutoSize = true;
            this.chkSelectAll.Location = new System.Drawing.Point(30, 68);
            this.chkSelectAll.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.chkSelectAll.Name = "chkSelectAll";
            this.chkSelectAll.Size = new System.Drawing.Size(74, 19);
            this.chkSelectAll.TabIndex = 55;
            this.chkSelectAll.Text = "Select All";
            this.chkSelectAll.UseVisualStyleBackColor = true;
            this.chkSelectAll.CheckedChanged += new System.EventHandler(this.chkSelectAll_CheckedChanged);
            // 
            // lblQuiet
            // 
            this.lblQuiet.AutoSize = true;
            this.lblQuiet.Location = new System.Drawing.Point(14, 13);
            this.lblQuiet.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.lblQuiet.Name = "lblQuiet";
            this.lblQuiet.Size = new System.Drawing.Size(70, 15);
            this.lblQuiet.TabIndex = 51;
            this.lblQuiet.Text = "Quiet Timer";
            // 
            // chkEnableFastID
            // 
            this.chkEnableFastID.AutoSize = true;
            this.chkEnableFastID.Location = new System.Drawing.Point(105, 68);
            this.chkEnableFastID.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.chkEnableFastID.Name = "chkEnableFastID";
            this.chkEnableFastID.Size = new System.Drawing.Size(58, 19);
            this.chkEnableFastID.TabIndex = 50;
            this.chkEnableFastID.Text = "FastID";
            this.chkEnableFastID.UseVisualStyleBackColor = true;
            this.chkEnableFastID.CheckedChanged += new System.EventHandler(this.ChkFastID_CheckedChanged);
            // 
            // chkTagFocus
            // 
            this.chkTagFocus.AutoSize = true;
            this.chkTagFocus.Location = new System.Drawing.Point(173, 68);
            this.chkTagFocus.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.chkTagFocus.Name = "chkTagFocus";
            this.chkTagFocus.Size = new System.Drawing.Size(57, 19);
            this.chkTagFocus.TabIndex = 49;
            this.chkTagFocus.Text = "Focus";
            this.chkTagFocus.UseVisualStyleBackColor = true;
            this.chkTagFocus.CheckedChanged += new System.EventHandler(this.ChkTagFocus_CheckedChanged);
            // 
            // btnSetTagQuiet
            // 
            this.btnSetTagQuiet.BackColor = System.Drawing.SystemColors.ButtonHighlight;
            this.btnSetTagQuiet.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("btnSetTagQuiet.BackgroundImage")));
            this.btnSetTagQuiet.FlatAppearance.BorderColor = System.Drawing.Color.Black;
            this.btnSetTagQuiet.FlatAppearance.BorderSize = 0;
            this.btnSetTagQuiet.FlatAppearance.MouseDownBackColor = System.Drawing.Color.Transparent;
            this.btnSetTagQuiet.FlatAppearance.MouseOverBackColor = System.Drawing.Color.Transparent;
            this.btnSetTagQuiet.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnSetTagQuiet.Font = new System.Drawing.Font("Microsoft Sans Serif", 7.8F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnSetTagQuiet.ForeColor = System.Drawing.Color.White;
            this.btnSetTagQuiet.Location = new System.Drawing.Point(211, 8);
            this.btnSetTagQuiet.Name = "btnSetTagQuiet";
            this.btnSetTagQuiet.Size = new System.Drawing.Size(83, 28);
            this.btnSetTagQuiet.TabIndex = 48;
            this.btnSetTagQuiet.Text = "QUIET";
            this.btnSetTagQuiet.UseVisualStyleBackColor = false;
            this.btnSetTagQuiet.Click += new System.EventHandler(this.btnSetTagQuiet_Click);
            // 
            // grdTags
            // 
            this.grdTags.AllowUserToAddRows = false;
            this.grdTags.AllowUserToDeleteRows = false;
            this.grdTags.AllowUserToOrderColumns = true;
            this.grdTags.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.grdTags.BackgroundColor = System.Drawing.Color.White;
            this.grdTags.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.grdTags.Location = new System.Drawing.Point(5, 91);
            this.grdTags.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.grdTags.Name = "grdTags";
            this.grdTags.RowHeadersWidth = 51;
            this.grdTags.RowTemplate.Height = 24;
            this.grdTags.Size = new System.Drawing.Size(1091, 438);
            this.grdTags.TabIndex = 47;
            this.grdTags.CellMouseClick += new System.Windows.Forms.DataGridViewCellMouseEventHandler(this.grdTags_CellMouseClick);
            // 
            // comboBoxReaders
            // 
            this.comboBoxReaders.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.comboBoxReaders.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.comboBoxReaders.Font = new System.Drawing.Font("Segoe UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.comboBoxReaders.FormattingEnabled = true;
            this.comboBoxReaders.IntegralHeight = false;
            this.comboBoxReaders.ItemHeight = 15;
            this.comboBoxReaders.Location = new System.Drawing.Point(17, 56);
            this.comboBoxReaders.Name = "comboBoxReaders";
            this.comboBoxReaders.Size = new System.Drawing.Size(760, 23);
            this.comboBoxReaders.TabIndex = 0;
            this.comboBoxReaders.SelectedIndexChanged += new System.EventHandler(this.ComboBoxReaders_SelectedIndexChanged);
            // 
            // lblReaders
            // 
            this.lblReaders.AutoSize = true;
            this.lblReaders.BackColor = System.Drawing.Color.Transparent;
            this.lblReaders.Font = new System.Drawing.Font("Microsoft Sans Serif", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblReaders.ForeColor = System.Drawing.SystemColors.ActiveCaptionText;
            this.lblReaders.Location = new System.Drawing.Point(18, 35);
            this.lblReaders.Margin = new System.Windows.Forms.Padding(0);
            this.lblReaders.Name = "lblReaders";
            this.lblReaders.Size = new System.Drawing.Size(119, 15);
            this.lblReaders.TabIndex = 10;
            this.lblReaders.Text = "Active RFID Readers";
            // 
            // lblLog
            // 
            this.lblLog.AutoSize = true;
            this.lblLog.BackColor = System.Drawing.Color.Transparent;
            this.lblLog.Font = new System.Drawing.Font("Segoe UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblLog.ForeColor = System.Drawing.SystemColors.ActiveCaptionText;
            this.lblLog.Location = new System.Drawing.Point(16, 339);
            this.lblLog.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.lblLog.Name = "lblLog";
            this.lblLog.Size = new System.Drawing.Size(27, 15);
            this.lblLog.TabIndex = 16;
            this.lblLog.Text = "Log";
            this.lblLog.Click += new System.EventHandler(this.lblLog_Click);
            // 
            // btnInventoryStart
            // 
            this.btnInventoryStart.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.btnInventoryStart.BackColor = System.Drawing.SystemColors.ButtonHighlight;
            this.btnInventoryStart.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("btnInventoryStart.BackgroundImage")));
            this.btnInventoryStart.FlatAppearance.BorderColor = System.Drawing.Color.Black;
            this.btnInventoryStart.FlatAppearance.BorderSize = 0;
            this.btnInventoryStart.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnInventoryStart.Font = new System.Drawing.Font("Microsoft Sans Serif", 7.8F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnInventoryStart.ForeColor = System.Drawing.Color.White;
            this.btnInventoryStart.Location = new System.Drawing.Point(20, 649);
            this.btnInventoryStart.Name = "btnInventoryStart";
            this.btnInventoryStart.Size = new System.Drawing.Size(145, 28);
            this.btnInventoryStart.TabIndex = 53;
            this.btnInventoryStart.Text = "START INVENTORY";
            this.btnInventoryStart.UseVisualStyleBackColor = false;
            this.btnInventoryStart.Click += new System.EventHandler(this.BtnInventoryStart_Click);
            // 
            // btnPurgeTags
            // 
            this.btnPurgeTags.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnPurgeTags.BackColor = System.Drawing.SystemColors.ButtonHighlight;
            this.btnPurgeTags.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("btnPurgeTags.BackgroundImage")));
            this.btnPurgeTags.FlatAppearance.BorderColor = System.Drawing.Color.Black;
            this.btnPurgeTags.FlatAppearance.BorderSize = 0;
            this.btnPurgeTags.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnPurgeTags.Font = new System.Drawing.Font("Microsoft Sans Serif", 7.8F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnPurgeTags.ForeColor = System.Drawing.Color.White;
            this.btnPurgeTags.Location = new System.Drawing.Point(991, 649);
            this.btnPurgeTags.Name = "btnPurgeTags";
            this.btnPurgeTags.Size = new System.Drawing.Size(129, 28);
            this.btnPurgeTags.TabIndex = 55;
            this.btnPurgeTags.Text = "CLEAR";
            this.btnPurgeTags.UseVisualStyleBackColor = false;
            this.btnPurgeTags.Click += new System.EventHandler(this.BtnPurgeTags_Click);
            // 
            // btnInventoryStop
            // 
            this.btnInventoryStop.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.btnInventoryStop.BackColor = System.Drawing.SystemColors.ButtonHighlight;
            this.btnInventoryStop.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("btnInventoryStop.BackgroundImage")));
            this.btnInventoryStop.FlatAppearance.BorderColor = System.Drawing.Color.Black;
            this.btnInventoryStop.FlatAppearance.BorderSize = 0;
            this.btnInventoryStop.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnInventoryStop.Font = new System.Drawing.Font("Microsoft Sans Serif", 7.8F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnInventoryStop.ForeColor = System.Drawing.Color.White;
            this.btnInventoryStop.Location = new System.Drawing.Point(171, 649);
            this.btnInventoryStop.Name = "btnInventoryStop";
            this.btnInventoryStop.Size = new System.Drawing.Size(131, 28);
            this.btnInventoryStop.TabIndex = 54;
            this.btnInventoryStop.Text = "STOP";
            this.btnInventoryStop.UseVisualStyleBackColor = false;
            this.btnInventoryStop.Click += new System.EventHandler(this.BtnInventoryStop_Click);
            // 
            // btnManualConnect
            // 
            this.btnManualConnect.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.btnManualConnect.BackColor = System.Drawing.SystemColors.ButtonHighlight;
            this.btnManualConnect.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("btnManualConnect.BackgroundImage")));
            this.btnManualConnect.FlatAppearance.BorderColor = System.Drawing.Color.Black;
            this.btnManualConnect.FlatAppearance.BorderSize = 0;
            this.btnManualConnect.FlatAppearance.MouseDownBackColor = System.Drawing.Color.CornflowerBlue;
            this.btnManualConnect.FlatAppearance.MouseOverBackColor = System.Drawing.Color.CornflowerBlue;
            this.btnManualConnect.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnManualConnect.Font = new System.Drawing.Font("Microsoft Sans Serif", 7.8F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnManualConnect.ForeColor = System.Drawing.Color.White;
            this.btnManualConnect.Location = new System.Drawing.Point(892, 53);
            this.btnManualConnect.Name = "btnManualConnect";
            this.btnManualConnect.Size = new System.Drawing.Size(96, 28);
            this.btnManualConnect.TabIndex = 52;
            this.btnManualConnect.Text = "COM";
            this.btnManualConnect.UseVisualStyleBackColor = false;
            this.btnManualConnect.Click += new System.EventHandler(this.btnManualConnect_Click);
            // 
            // btnConnectDisconnect
            // 
            this.btnConnectDisconnect.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.btnConnectDisconnect.BackColor = System.Drawing.SystemColors.ButtonHighlight;
            this.btnConnectDisconnect.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("btnConnectDisconnect.BackgroundImage")));
            this.btnConnectDisconnect.FlatAppearance.BorderColor = System.Drawing.Color.Black;
            this.btnConnectDisconnect.FlatAppearance.BorderSize = 0;
            this.btnConnectDisconnect.FlatAppearance.MouseDownBackColor = System.Drawing.Color.Transparent;
            this.btnConnectDisconnect.FlatAppearance.MouseOverBackColor = System.Drawing.Color.Transparent;
            this.btnConnectDisconnect.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnConnectDisconnect.Font = new System.Drawing.Font("Microsoft Sans Serif", 7.8F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnConnectDisconnect.ForeColor = System.Drawing.Color.White;
            this.btnConnectDisconnect.Location = new System.Drawing.Point(994, 53);
            this.btnConnectDisconnect.Name = "btnConnectDisconnect";
            this.btnConnectDisconnect.Size = new System.Drawing.Size(123, 28);
            this.btnConnectDisconnect.TabIndex = 1;
            this.btnConnectDisconnect.Text = "CONNECT";
            this.btnConnectDisconnect.UseVisualStyleBackColor = false;
            this.btnConnectDisconnect.Click += new System.EventHandler(this.BtnConnectDisconnect_Click);
            // 
            // btnPairNew
            // 
            this.btnPairNew.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.btnPairNew.BackColor = System.Drawing.SystemColors.ButtonHighlight;
            this.btnPairNew.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("btnPairNew.BackgroundImage")));
            this.btnPairNew.FlatAppearance.BorderColor = System.Drawing.Color.Black;
            this.btnPairNew.FlatAppearance.BorderSize = 0;
            this.btnPairNew.FlatAppearance.MouseDownBackColor = System.Drawing.Color.CornflowerBlue;
            this.btnPairNew.FlatAppearance.MouseOverBackColor = System.Drawing.Color.CornflowerBlue;
            this.btnPairNew.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnPairNew.Font = new System.Drawing.Font("Microsoft Sans Serif", 7.8F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnPairNew.ForeColor = System.Drawing.Color.White;
            this.btnPairNew.Location = new System.Drawing.Point(790, 53);
            this.btnPairNew.Name = "btnPairNew";
            this.btnPairNew.Size = new System.Drawing.Size(96, 28);
            this.btnPairNew.TabIndex = 31;
            this.btnPairNew.Text = "PAIR";
            this.btnPairNew.UseVisualStyleBackColor = false;
            this.btnPairNew.Click += new System.EventHandler(this.BtnPairNew_Click);
            // 
            // menuStrip1
            // 
            this.menuStrip1.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("menuStrip1.BackgroundImage")));
            this.menuStrip1.ImageScalingSize = new System.Drawing.Size(20, 20);
            this.menuStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.settingsMenuItem,
            this.helpMenuItem});
            this.menuStrip1.Location = new System.Drawing.Point(0, 0);
            this.menuStrip1.Name = "menuStrip1";
            this.menuStrip1.Padding = new System.Windows.Forms.Padding(4, 2, 0, 2);
            this.menuStrip1.Size = new System.Drawing.Size(1141, 24);
            this.menuStrip1.TabIndex = 19;
            this.menuStrip1.Text = "menuStrip1";
            // 
            // settingsMenuItem
            // 
            this.settingsMenuItem.Checked = true;
            this.settingsMenuItem.CheckState = System.Windows.Forms.CheckState.Indeterminate;
            this.settingsMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.singulationMenuItem,
            this.preFilters,
            this.customTagQuietingToolStripMenuItem,
            this.protectedModeToolStripMenuItem,
            this.InventoryProtocolToolStripMenuItem});
            this.settingsMenuItem.Name = "settingsMenuItem";
            this.settingsMenuItem.Size = new System.Drawing.Size(61, 20);
            this.settingsMenuItem.Text = "&Settings";
            this.settingsMenuItem.Click += new System.EventHandler(this.settingsMenuItem_Click);
            // 
            // singulationMenuItem
            // 
            this.singulationMenuItem.Name = "singulationMenuItem";
            this.singulationMenuItem.Size = new System.Drawing.Size(187, 22);
            this.singulationMenuItem.Text = "Singulation";
            this.singulationMenuItem.Click += new System.EventHandler(this.SingulationToolStripMenuItem_Click);
            // 
            // preFilters
            // 
            this.preFilters.Name = "preFilters";
            this.preFilters.Size = new System.Drawing.Size(187, 22);
            this.preFilters.Text = "Pre Filters";
            this.preFilters.Click += new System.EventHandler(this.preFilters_Click);
            // 
            // customTagQuietingToolStripMenuItem
            // 
            this.customTagQuietingToolStripMenuItem.Name = "customTagQuietingToolStripMenuItem";
            this.customTagQuietingToolStripMenuItem.Size = new System.Drawing.Size(187, 22);
            this.customTagQuietingToolStripMenuItem.Text = "Custom Tag Quieting";
            this.customTagQuietingToolStripMenuItem.Click += new System.EventHandler(this.CustomTagQuietingToolStripMenuItem_Click);
            // 
            // protectedModeToolStripMenuItem
            // 
            this.protectedModeToolStripMenuItem.Name = "protectedModeToolStripMenuItem";
            this.protectedModeToolStripMenuItem.Size = new System.Drawing.Size(187, 22);
            this.protectedModeToolStripMenuItem.Text = "Protected Mode";
            this.protectedModeToolStripMenuItem.Click += new System.EventHandler(this.ProtectedModeToolStripMenuItem_Click);
            // 
            // InventoryProtocolToolStripMenuItem
            // 
            this.InventoryProtocolToolStripMenuItem.Name = "InventoryProtocolToolStripMenuItem";
            this.InventoryProtocolToolStripMenuItem.Size = new System.Drawing.Size(187, 22);
            this.InventoryProtocolToolStripMenuItem.Text = "Inventory Protocol";
            this.InventoryProtocolToolStripMenuItem.Click += new System.EventHandler(this.InventoryProtocolToolStripMenuItem_Click);
            // 
            // helpMenuItem
            // 
            this.helpMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.aboutToolStripMenuItem});
            this.helpMenuItem.Name = "helpMenuItem";
            this.helpMenuItem.Size = new System.Drawing.Size(44, 20);
            this.helpMenuItem.Text = "&Help";
            // 
            // aboutToolStripMenuItem
            // 
            this.aboutToolStripMenuItem.Name = "aboutToolStripMenuItem";
            this.aboutToolStripMenuItem.Size = new System.Drawing.Size(107, 22);
            this.aboutToolStripMenuItem.Text = "&About";
            this.aboutToolStripMenuItem.Click += new System.EventHandler(this.AboutToolStripMenuItem_Click);
            // 
            // txtOutput
            // 
            this.txtOutput.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.txtOutput.BackColor = System.Drawing.SystemColors.ControlLightLight;
            this.txtOutput.Font = new System.Drawing.Font("Segoe UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.txtOutput.Location = new System.Drawing.Point(17, 683);
            this.txtOutput.Multiline = true;
            this.txtOutput.Name = "txtOutput";
            this.txtOutput.ReadOnly = true;
            this.txtOutput.ScrollBars = System.Windows.Forms.ScrollBars.Both;
            this.txtOutput.Size = new System.Drawing.Size(1107, 91);
            this.txtOutput.TabIndex = 5;
            this.txtOutput.TabStop = false;
            // 
            // lblStatusMsg
            // 
            this.lblStatusMsg.Anchor = System.Windows.Forms.AnchorStyles.Top;
            this.lblStatusMsg.AutoSize = true;
            this.lblStatusMsg.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblStatusMsg.ForeColor = System.Drawing.Color.Navy;
            this.lblStatusMsg.Location = new System.Drawing.Point(432, 35);
            this.lblStatusMsg.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.lblStatusMsg.Name = "lblStatusMsg";
            this.lblStatusMsg.Size = new System.Drawing.Size(189, 13);
            this.lblStatusMsg.TabIndex = 56;
            this.lblStatusMsg.Text = "USB reader discovery is in progress.....";
            this.lblStatusMsg.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // frmMain
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.SystemColors.Control;
            this.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.ClientSize = new System.Drawing.Size(1141, 777);
            this.Controls.Add(this.lblStatusMsg);
            this.Controls.Add(this.btnInventoryStart);
            this.Controls.Add(this.btnPurgeTags);
            this.Controls.Add(this.btnInventoryStop);
            this.Controls.Add(this.btnManualConnect);
            this.Controls.Add(tabContainer);
            this.Controls.Add(this.btnConnectDisconnect);
            this.Controls.Add(this.btnPairNew);
            this.Controls.Add(this.menuStrip1);
            this.Controls.Add(this.lblLog);
            this.Controls.Add(this.lblReaders);
            this.Controls.Add(this.txtOutput);
            this.Controls.Add(this.comboBoxReaders);
            this.DoubleBuffered = true;
            this.ForeColor = System.Drawing.Color.Black;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.MainMenuStrip = this.menuStrip1;
            this.MinimumSize = new System.Drawing.Size(720, 532);
            this.Name = "frmMain";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "NewGen2XPlay";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.FrmAppMain_FormClosing);
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.frmMain_FormClosed);
            this.Load += new System.EventHandler(this.FrmAppMain_Load);
            tabContainer.ResumeLayout(false);
            this.tabInventory.ResumeLayout(false);
            this.tabInventory.PerformLayout();
            this.panel1.ResumeLayout(false);
            this.panel1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.grdTags)).EndInit();
            this.menuStrip1.ResumeLayout(false);
            this.menuStrip1.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private ComboBox comboBoxReaders;
        private Button btnConnectDisconnect;
        private Label lblReaders;
        private MenuStrip menuStrip1;
        private ToolStripMenuItem settingsMenuItem;
        private ToolStripMenuItem helpMenuItem;
        private ToolStripMenuItem aboutToolStripMenuItem;
        private Button btnPairNew;
        private ToolStripMenuItem singulationMenuItem;
        private ToolStripMenuItem preFilters;
        private Button btnManualConnect;
        private Label lblLog;
        private ToolStripMenuItem customTagQuietingToolStripMenuItem;
        private ToolStripMenuItem protectedModeToolStripMenuItem;
        private Button btnInventoryStart;
        private Button btnPurgeTags;
        private Button btnInventoryStop;
        private ToolStripMenuItem InventoryProtocolToolStripMenuItem;
        private TextBox txtOutput;
        private TabPage tabInventory;
        private Button btnUnquiet;
        private TextBox txtQuietTime;
        private Label lblQuiet;
        private Button btnSetTagQuiet;
        private DataGridView grdTags;
        private CheckBox chkSelectAll;
        private CheckBox chkEnableFastID;
        private CheckBox chkTagFocus;
        private TextBox txtStopTimer;
        private Label label1;
        private Panel panel1;
        private Label lblReadRatew;
        private Label lblReadRate;
        private Label lblGreen;
        private Label lblGray;
        private Label lblW;
        private Label lblY;
        private Label lblUtgs;
        private Label lblunqtags;
        private Label lblTime;
        private Label label2;
        private Label label3;
        private Label lbluniquetgs10s;
        private Label lblStatusMsg;
        private Label lblTotalReadCount;
        private Label label4;
    }
}

