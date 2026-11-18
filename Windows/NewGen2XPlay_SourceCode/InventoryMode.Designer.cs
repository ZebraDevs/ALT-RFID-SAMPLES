namespace Symbol.RFID.SDK.ZEBRAGen2XDemoApp
{
    partial class InventoryMode
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
            this.label1 = new System.Windows.Forms.Label();
            this.rdGen2 = new System.Windows.Forms.RadioButton();
            this.rdGen2x = new System.Windows.Forms.RadioButton();
            this.rdHybrid = new System.Windows.Forms.RadioButton();
            this.BtnSave = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(41, 41);
            this.label1.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(120, 16);
            this.label1.TabIndex = 0;
            this.label1.Text = "Inventory Protocol :";
            // 
            // rdGen2
            // 
            this.rdGen2.AutoSize = true;
            this.rdGen2.Location = new System.Drawing.Point(181, 41);
            this.rdGen2.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.rdGen2.Name = "rdGen2";
            this.rdGen2.Size = new System.Drawing.Size(60, 20);
            this.rdGen2.TabIndex = 1;
            this.rdGen2.TabStop = true;
            this.rdGen2.Text = "Gen2";
            this.rdGen2.UseVisualStyleBackColor = true;
            // 
            // rdGen2x
            // 
            this.rdGen2x.AutoSize = true;
            this.rdGen2x.Location = new System.Drawing.Point(257, 41);
            this.rdGen2x.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.rdGen2x.Name = "rdGen2x";
            this.rdGen2x.Size = new System.Drawing.Size(68, 20);
            this.rdGen2x.TabIndex = 2;
            this.rdGen2x.TabStop = true;
            this.rdGen2x.Text = "Gen2X";
            this.rdGen2x.UseVisualStyleBackColor = true;
            // 
            // rdHybrid
            // 
            this.rdHybrid.AutoSize = true;
            this.rdHybrid.Location = new System.Drawing.Point(343, 41);
            this.rdHybrid.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.rdHybrid.Name = "rdHybrid";
            this.rdHybrid.Size = new System.Drawing.Size(68, 20);
            this.rdHybrid.TabIndex = 3;
            this.rdHybrid.TabStop = true;
            this.rdHybrid.Text = "Hybrid";
            this.rdHybrid.UseVisualStyleBackColor = true;
            // 
            // BtnSave
            // 
            this.BtnSave.Location = new System.Drawing.Point(181, 84);
            this.BtnSave.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.BtnSave.Name = "BtnSave";
            this.BtnSave.Size = new System.Drawing.Size(124, 31);
            this.BtnSave.TabIndex = 4;
            this.BtnSave.Text = "SAVE";
            this.BtnSave.UseVisualStyleBackColor = true;
            this.BtnSave.Click += new System.EventHandler(this.button1_Click);
            // 
            // InventoryMode
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(457, 146);
            this.Controls.Add(this.BtnSave);
            this.Controls.Add(this.rdHybrid);
            this.Controls.Add(this.rdGen2x);
            this.Controls.Add(this.rdGen2);
            this.Controls.Add(this.label1);
            this.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "InventoryMode";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "Inventory Protocol";
            this.Load += new System.EventHandler(this.InventoryMode_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.RadioButton rdGen2;
        private System.Windows.Forms.RadioButton rdGen2x;
        private System.Windows.Forms.RadioButton rdHybrid;
        private System.Windows.Forms.Button BtnSave;
    }
}