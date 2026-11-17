using System.ComponentModel;
using System.Windows.Forms;

namespace Symbol.RFID.SDK.ZEBRAGen2XDemoApp
{
    partial class Singulation
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(Singulation));
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.cmbSlFlag = new System.Windows.Forms.ComboBox();
            this.labelSlFlag = new System.Windows.Forms.Label();
            this.cmbInventoryState = new System.Windows.Forms.ComboBox();
            this.labelInState = new System.Windows.Forms.Label();
            this.cmbSession = new System.Windows.Forms.ComboBox();
            this.lblSession = new System.Windows.Forms.Label();
            this.btnApply = new System.Windows.Forms.Button();
            this.lblPopulation = new System.Windows.Forms.Label();
            this.txtTagPopulation = new System.Windows.Forms.TextBox();
            this.groupBox2.SuspendLayout();
            this.SuspendLayout();
            // 
            // groupBox2
            // 
            this.groupBox2.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.groupBox2.BackColor = System.Drawing.Color.Transparent;
            this.groupBox2.Controls.Add(this.txtTagPopulation);
            this.groupBox2.Controls.Add(this.cmbSlFlag);
            this.groupBox2.Controls.Add(this.labelSlFlag);
            this.groupBox2.Controls.Add(this.cmbInventoryState);
            this.groupBox2.Controls.Add(this.labelInState);
            this.groupBox2.Controls.Add(this.cmbSession);
            this.groupBox2.Controls.Add(this.lblPopulation);
            this.groupBox2.Controls.Add(this.lblSession);
            this.groupBox2.ForeColor = System.Drawing.SystemColors.Desktop;
            this.groupBox2.Location = new System.Drawing.Point(6, 14);
            this.groupBox2.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.Padding = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.groupBox2.Size = new System.Drawing.Size(456, 200);
            this.groupBox2.TabIndex = 0;
            this.groupBox2.TabStop = false;
            this.groupBox2.Text = "Singulation";
            // 
            // cmbSlFlag
            // 
            this.cmbSlFlag.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cmbSlFlag.FormattingEnabled = true;
            this.cmbSlFlag.Location = new System.Drawing.Point(201, 154);
            this.cmbSlFlag.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.cmbSlFlag.Name = "cmbSlFlag";
            this.cmbSlFlag.Size = new System.Drawing.Size(239, 24);
            this.cmbSlFlag.TabIndex = 7;
            // 
            // labelSlFlag
            // 
            this.labelSlFlag.AutoSize = true;
            this.labelSlFlag.Location = new System.Drawing.Point(23, 157);
            this.labelSlFlag.Name = "labelSlFlag";
            this.labelSlFlag.Size = new System.Drawing.Size(53, 16);
            this.labelSlFlag.TabIndex = 6;
            this.labelSlFlag.Text = "SL Flag";
            // 
            // cmbInventoryState
            // 
            this.cmbInventoryState.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cmbInventoryState.FormattingEnabled = true;
            this.cmbInventoryState.Location = new System.Drawing.Point(201, 111);
            this.cmbInventoryState.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.cmbInventoryState.Name = "cmbInventoryState";
            this.cmbInventoryState.Size = new System.Drawing.Size(239, 24);
            this.cmbInventoryState.TabIndex = 5;
            // 
            // labelInState
            // 
            this.labelInState.AutoSize = true;
            this.labelInState.Location = new System.Drawing.Point(23, 119);
            this.labelInState.Name = "labelInState";
            this.labelInState.Size = new System.Drawing.Size(95, 16);
            this.labelInState.TabIndex = 4;
            this.labelInState.Text = "Inventory State";
            // 
            // cmbSession
            // 
            this.cmbSession.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cmbSession.FormattingEnabled = true;
            this.cmbSession.Location = new System.Drawing.Point(201, 69);
            this.cmbSession.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.cmbSession.Name = "cmbSession";
            this.cmbSession.Size = new System.Drawing.Size(239, 24);
            this.cmbSession.TabIndex = 1;
            // 
            // lblSession
            // 
            this.lblSession.AutoSize = true;
            this.lblSession.Location = new System.Drawing.Point(23, 77);
            this.lblSession.Name = "lblSession";
            this.lblSession.Size = new System.Drawing.Size(56, 16);
            this.lblSession.TabIndex = 0;
            this.lblSession.Text = "Session";
            // 
            // btnApply
            // 
            this.btnApply.BackColor = System.Drawing.SystemColors.ButtonHighlight;
            this.btnApply.DialogResult = System.Windows.Forms.DialogResult.OK;
            this.btnApply.Font = new System.Drawing.Font("Microsoft Sans Serif", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnApply.ForeColor = System.Drawing.SystemColors.ControlText;
            this.btnApply.Location = new System.Drawing.Point(327, 218);
            this.btnApply.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.btnApply.Name = "btnApply";
            this.btnApply.Size = new System.Drawing.Size(119, 34);
            this.btnApply.TabIndex = 1;
            this.btnApply.Text = "Save";
            this.btnApply.UseVisualStyleBackColor = false;
            this.btnApply.Click += new System.EventHandler(this.BtnApply_Click);
            // 
            // lblPopulation
            // 
            this.lblPopulation.AutoSize = true;
            this.lblPopulation.Location = new System.Drawing.Point(23, 36);
            this.lblPopulation.Name = "lblPopulation";
            this.lblPopulation.Size = new System.Drawing.Size(99, 16);
            this.lblPopulation.TabIndex = 2;
            this.lblPopulation.Text = "Tag Population";
            // 
            // txtTagPopulation
            // 
            this.txtTagPopulation.CharacterCasing = System.Windows.Forms.CharacterCasing.Upper;
            this.txtTagPopulation.Location = new System.Drawing.Point(201, 30);
            this.txtTagPopulation.Margin = new System.Windows.Forms.Padding(4);
            this.txtTagPopulation.Name = "txtTagPopulation";
            this.txtTagPopulation.Size = new System.Drawing.Size(239, 22);
            this.txtTagPopulation.TabIndex = 8;
            this.txtTagPopulation.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.NumericInput_KeyPress);
            // 
            // Singulation
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("$this.BackgroundImage")));
            this.ClientSize = new System.Drawing.Size(474, 269);
            this.Controls.Add(this.btnApply);
            this.Controls.Add(this.groupBox2);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "Singulation";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "Singulation";
            this.Load += new System.EventHandler(this.FrmSingulation_Load);
            this.groupBox2.ResumeLayout(false);
            this.groupBox2.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private GroupBox groupBox2;
        private ComboBox cmbSession;
        private Label lblSession;
        private Button btnApply;
        private ComboBox cmbSlFlag;
        private Label labelSlFlag;
        private ComboBox cmbInventoryState;
        private Label labelInState;
        private TextBox txtTagPopulation;
        private Label lblPopulation;
    }
}