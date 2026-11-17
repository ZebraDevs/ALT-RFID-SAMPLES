namespace Symbol.RFID.SDK.ZEBRAGen2XDemoApp
{
    partial class PreFilters
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

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
            this.labelFilter = new System.Windows.Forms.Label();
            this.labelTagPattern = new System.Windows.Forms.Label();
            this.gbPreFilters = new System.Windows.Forms.GroupBox();
            this.chkEnable = new System.Windows.Forms.CheckBox();
            this.label2 = new System.Windows.Forms.Label();
            this.txtFilterLength = new System.Windows.Forms.TextBox();
            this.txtOffSet = new System.Windows.Forms.TextBox();
            this.cmbMemoryBank = new System.Windows.Forms.ComboBox();
            this.cmbAction = new System.Windows.Forms.ComboBox();
            this.cmbTarget = new System.Windows.Forms.ComboBox();
            this.txtTagPattern = new System.Windows.Forms.TextBox();
            this.labelOffset = new System.Windows.Forms.Label();
            this.labelMemBank = new System.Windows.Forms.Label();
            this.labelAction = new System.Windows.Forms.Label();
            this.labelTarget = new System.Windows.Forms.Label();
            this.cmbFilters = new System.Windows.Forms.ComboBox();
            this.BtnDeleteAllFilters = new System.Windows.Forms.Button();
            this.BtnSaveFilter = new System.Windows.Forms.Button();
            this.btnDel = new System.Windows.Forms.Button();
            this.gbPreFilters.SuspendLayout();
            this.SuspendLayout();
            // 
            // labelFilter
            // 
            this.labelFilter.AutoSize = true;
            this.labelFilter.Location = new System.Drawing.Point(22, 287);
            this.labelFilter.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.labelFilter.Name = "labelFilter";
            this.labelFilter.Size = new System.Drawing.Size(29, 13);
            this.labelFilter.TabIndex = 7;
            this.labelFilter.Text = "Filter";
            // 
            // labelTagPattern
            // 
            this.labelTagPattern.AutoSize = true;
            this.labelTagPattern.Location = new System.Drawing.Point(15, 23);
            this.labelTagPattern.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.labelTagPattern.Name = "labelTagPattern";
            this.labelTagPattern.Size = new System.Drawing.Size(63, 13);
            this.labelTagPattern.TabIndex = 9;
            this.labelTagPattern.Text = "Tag Pattern";
            // 
            // gbPreFilters
            // 
            this.gbPreFilters.Controls.Add(this.chkEnable);
            this.gbPreFilters.Controls.Add(this.label2);
            this.gbPreFilters.Controls.Add(this.txtFilterLength);
            this.gbPreFilters.Controls.Add(this.txtOffSet);
            this.gbPreFilters.Controls.Add(this.cmbMemoryBank);
            this.gbPreFilters.Controls.Add(this.cmbAction);
            this.gbPreFilters.Controls.Add(this.cmbTarget);
            this.gbPreFilters.Controls.Add(this.txtTagPattern);
            this.gbPreFilters.Controls.Add(this.labelOffset);
            this.gbPreFilters.Controls.Add(this.labelMemBank);
            this.gbPreFilters.Controls.Add(this.labelAction);
            this.gbPreFilters.Controls.Add(this.labelTarget);
            this.gbPreFilters.Controls.Add(this.labelTagPattern);
            this.gbPreFilters.Location = new System.Drawing.Point(9, 10);
            this.gbPreFilters.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.gbPreFilters.Name = "gbPreFilters";
            this.gbPreFilters.Padding = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.gbPreFilters.Size = new System.Drawing.Size(347, 256);
            this.gbPreFilters.TabIndex = 0;
            this.gbPreFilters.TabStop = false;
            this.gbPreFilters.Text = "Pre Filters";
            // 
            // chkEnable
            // 
            this.chkEnable.AutoSize = true;
            this.chkEnable.Location = new System.Drawing.Point(159, 232);
            this.chkEnable.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.chkEnable.Name = "chkEnable";
            this.chkEnable.Size = new System.Drawing.Size(59, 17);
            this.chkEnable.TabIndex = 17;
            this.chkEnable.Text = "Enable";
            this.chkEnable.UseVisualStyleBackColor = true;
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(16, 202);
            this.label2.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(40, 13);
            this.label2.TabIndex = 15;
            this.label2.Text = "Length";
            this.label2.Visible = false;
            // 
            // txtFilterLength
            // 
            this.txtFilterLength.Location = new System.Drawing.Point(159, 202);
            this.txtFilterLength.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.txtFilterLength.Name = "txtFilterLength";
            this.txtFilterLength.Size = new System.Drawing.Size(180, 20);
            this.txtFilterLength.TabIndex = 14;
            this.txtFilterLength.Text = "4";
            this.txtFilterLength.Visible = false;
            // 
            // txtOffSet
            // 
            this.txtOffSet.Location = new System.Drawing.Point(159, 170);
            this.txtOffSet.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.txtOffSet.Name = "txtOffSet";
            this.txtOffSet.Size = new System.Drawing.Size(180, 20);
            this.txtOffSet.TabIndex = 6;
            this.txtOffSet.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.NumericInput_KeyPress);
            // 
            // cmbMemoryBank
            // 
            this.cmbMemoryBank.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cmbMemoryBank.FormattingEnabled = true;
            this.cmbMemoryBank.Location = new System.Drawing.Point(159, 136);
            this.cmbMemoryBank.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.cmbMemoryBank.Name = "cmbMemoryBank";
            this.cmbMemoryBank.Size = new System.Drawing.Size(180, 21);
            this.cmbMemoryBank.TabIndex = 4;
            // 
            // cmbAction
            // 
            this.cmbAction.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cmbAction.FormattingEnabled = true;
            this.cmbAction.Location = new System.Drawing.Point(159, 103);
            this.cmbAction.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.cmbAction.Name = "cmbAction";
            this.cmbAction.Size = new System.Drawing.Size(180, 21);
            this.cmbAction.TabIndex = 5;
            // 
            // cmbTarget
            // 
            this.cmbTarget.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cmbTarget.FormattingEnabled = true;
            this.cmbTarget.Location = new System.Drawing.Point(159, 69);
            this.cmbTarget.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.cmbTarget.Name = "cmbTarget";
            this.cmbTarget.Size = new System.Drawing.Size(180, 21);
            this.cmbTarget.TabIndex = 3;
            // 
            // txtTagPattern
            // 
            this.txtTagPattern.CharacterCasing = System.Windows.Forms.CharacterCasing.Upper;
            this.txtTagPattern.Location = new System.Drawing.Point(15, 37);
            this.txtTagPattern.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.txtTagPattern.Name = "txtTagPattern";
            this.txtTagPattern.Size = new System.Drawing.Size(324, 20);
            this.txtTagPattern.TabIndex = 2;
            this.txtTagPattern.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.HexInput_KeyPress);
            // 
            // labelOffset
            // 
            this.labelOffset.AutoSize = true;
            this.labelOffset.Location = new System.Drawing.Point(16, 175);
            this.labelOffset.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.labelOffset.Name = "labelOffset";
            this.labelOffset.Size = new System.Drawing.Size(40, 13);
            this.labelOffset.TabIndex = 13;
            this.labelOffset.Text = "Pointer";
            // 
            // labelMemBank
            // 
            this.labelMemBank.AutoSize = true;
            this.labelMemBank.Location = new System.Drawing.Point(15, 142);
            this.labelMemBank.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.labelMemBank.Name = "labelMemBank";
            this.labelMemBank.Size = new System.Drawing.Size(72, 13);
            this.labelMemBank.TabIndex = 11;
            this.labelMemBank.Text = "Memory Bank";
            // 
            // labelAction
            // 
            this.labelAction.AutoSize = true;
            this.labelAction.Location = new System.Drawing.Point(16, 110);
            this.labelAction.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.labelAction.Name = "labelAction";
            this.labelAction.Size = new System.Drawing.Size(37, 13);
            this.labelAction.TabIndex = 12;
            this.labelAction.Text = "Action";
            // 
            // labelTarget
            // 
            this.labelTarget.AutoSize = true;
            this.labelTarget.Location = new System.Drawing.Point(16, 76);
            this.labelTarget.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.labelTarget.Name = "labelTarget";
            this.labelTarget.Size = new System.Drawing.Size(38, 13);
            this.labelTarget.TabIndex = 10;
            this.labelTarget.Text = "Target";
            // 
            // cmbFilters
            // 
            this.cmbFilters.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cmbFilters.FormattingEnabled = true;
            this.cmbFilters.Location = new System.Drawing.Point(61, 285);
            this.cmbFilters.Name = "cmbFilters";
            this.cmbFilters.Size = new System.Drawing.Size(83, 21);
            this.cmbFilters.TabIndex = 14;
            this.cmbFilters.SelectedIndexChanged += new System.EventHandler(this.cmbFilters_SelectedIndexChanged);
            // 
            // BtnDeleteAllFilters
            // 
            this.BtnDeleteAllFilters.BackColor = System.Drawing.SystemColors.ButtonHighlight;
            this.BtnDeleteAllFilters.Location = new System.Drawing.Point(168, 319);
            this.BtnDeleteAllFilters.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.BtnDeleteAllFilters.Name = "BtnDeleteAllFilters";
            this.BtnDeleteAllFilters.Size = new System.Drawing.Size(179, 28);
            this.BtnDeleteAllFilters.TabIndex = 16;
            this.BtnDeleteAllFilters.Text = "DELETE ALL PREFILTERS";
            this.BtnDeleteAllFilters.UseVisualStyleBackColor = false;
            this.BtnDeleteAllFilters.Click += new System.EventHandler(this.BtnDeleteAllFilters_Click);
            // 
            // BtnSaveFilter
            // 
            this.BtnSaveFilter.BackColor = System.Drawing.SystemColors.ButtonHighlight;
            this.BtnSaveFilter.Location = new System.Drawing.Point(168, 280);
            this.BtnSaveFilter.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.BtnSaveFilter.Name = "BtnSaveFilter";
            this.BtnSaveFilter.Size = new System.Drawing.Size(88, 28);
            this.BtnSaveFilter.TabIndex = 1;
            this.BtnSaveFilter.Text = "SAVE";
            this.BtnSaveFilter.UseVisualStyleBackColor = false;
            this.BtnSaveFilter.Click += new System.EventHandler(this.BtnSaveFilter_Click);
            // 
            // btnDel
            // 
            this.btnDel.BackColor = System.Drawing.SystemColors.ButtonHighlight;
            this.btnDel.Location = new System.Drawing.Point(259, 280);
            this.btnDel.Margin = new System.Windows.Forms.Padding(2);
            this.btnDel.Name = "btnDel";
            this.btnDel.Size = new System.Drawing.Size(88, 28);
            this.btnDel.TabIndex = 17;
            this.btnDel.Text = "DELETE";
            this.btnDel.UseVisualStyleBackColor = false;
            this.btnDel.Click += new System.EventHandler(this.BtnDeleteFilter_Click);
            // 
            // PreFilters
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(365, 364);
            this.Controls.Add(this.btnDel);
            this.Controls.Add(this.BtnDeleteAllFilters);
            this.Controls.Add(this.cmbFilters);
            this.Controls.Add(this.BtnSaveFilter);
            this.Controls.Add(this.gbPreFilters);
            this.Controls.Add(this.labelFilter);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "PreFilters";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "Pre Filters";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.FrmAppMain_FormClosing);
            this.Load += new System.EventHandler(this.PreFilters_Load);
            this.gbPreFilters.ResumeLayout(false);
            this.gbPreFilters.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label labelFilter;
        private System.Windows.Forms.Label labelTagPattern;
        private System.Windows.Forms.GroupBox gbPreFilters;
        private System.Windows.Forms.TextBox txtOffSet;
        private System.Windows.Forms.ComboBox cmbMemoryBank;
        private System.Windows.Forms.ComboBox cmbAction;
        private System.Windows.Forms.ComboBox cmbTarget;
        private System.Windows.Forms.TextBox txtTagPattern;
        private System.Windows.Forms.Label labelOffset;
        private System.Windows.Forms.Label labelMemBank;
        private System.Windows.Forms.Label labelAction;
        private System.Windows.Forms.Label labelTarget;
        private System.Windows.Forms.ComboBox cmbFilters;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.TextBox txtFilterLength;
        private System.Windows.Forms.CheckBox chkEnable;
        private System.Windows.Forms.Button BtnDeleteAllFilters;
        private System.Windows.Forms.Button BtnSaveFilter;
        private System.Windows.Forms.Button btnDel;
    }
}