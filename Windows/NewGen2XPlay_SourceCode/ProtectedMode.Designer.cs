namespace Symbol.RFID.SDK.ZEBRAGen2XDemoApp
{
    partial class ProtectedMode
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
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.label4 = new System.Windows.Forms.Label();
            this.txtProtectPassword = new System.Windows.Forms.TextBox();
            this.label3 = new System.Windows.Forms.Label();
            this.cboProtectMode = new System.Windows.Forms.ComboBox();
            this.label2 = new System.Windows.Forms.Label();
            this.txtProtectTagPattern = new System.Windows.Forms.TextBox();
            this.label1 = new System.Windows.Forms.Label();
            this.btnPerformOperation = new System.Windows.Forms.Button();
            this.groupBox1.SuspendLayout();
            this.SuspendLayout();
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.label4);
            this.groupBox1.Controls.Add(this.txtProtectPassword);
            this.groupBox1.Controls.Add(this.label3);
            this.groupBox1.Controls.Add(this.cboProtectMode);
            this.groupBox1.Controls.Add(this.label2);
            this.groupBox1.Controls.Add(this.txtProtectTagPattern);
            this.groupBox1.Controls.Add(this.label1);
            this.groupBox1.Location = new System.Drawing.Point(9, 10);
            this.groupBox1.Margin = new System.Windows.Forms.Padding(2);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Padding = new System.Windows.Forms.Padding(2);
            this.groupBox1.Size = new System.Drawing.Size(342, 145);
            this.groupBox1.TabIndex = 0;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Protected Mode";
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(167, 122);
            this.label4.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(153, 13);
            this.label4.TabIndex = 6;
            this.label4.Text = "(8 chars, 32 bit HEX password)";
            // 
            // txtProtectPassword
            // 
            this.txtProtectPassword.Location = new System.Drawing.Point(120, 100);
            this.txtProtectPassword.Margin = new System.Windows.Forms.Padding(2);
            this.txtProtectPassword.MaxLength = 8;
            this.txtProtectPassword.Name = "txtProtectPassword";
            this.txtProtectPassword.Size = new System.Drawing.Size(200, 20);
            this.txtProtectPassword.TabIndex = 5;
            this.txtProtectPassword.TextChanged += new System.EventHandler(this.txtProtectPassword_TextChanged);
            this.txtProtectPassword.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.txtProtectPassword_KeyPress);
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(11, 103);
            this.label3.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(53, 13);
            this.label3.TabIndex = 4;
            this.label3.Text = "Password";
            // 
            // cboProtectMode
            // 
            this.cboProtectMode.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cboProtectMode.FormattingEnabled = true;
            this.cboProtectMode.Location = new System.Drawing.Point(120, 64);
            this.cboProtectMode.Margin = new System.Windows.Forms.Padding(2);
            this.cboProtectMode.Name = "cboProtectMode";
            this.cboProtectMode.Size = new System.Drawing.Size(200, 21);
            this.cboProtectMode.TabIndex = 3;
            this.cboProtectMode.SelectedIndexChanged += new System.EventHandler(this.cboProtectMode_SelectedIndexChanged);
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(11, 72);
            this.label2.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(34, 13);
            this.label2.TabIndex = 2;
            this.label2.Text = "Mode";
            // 
            // txtProtectTagPattern
            // 
            this.txtProtectTagPattern.Location = new System.Drawing.Point(14, 36);
            this.txtProtectTagPattern.Margin = new System.Windows.Forms.Padding(2);
            this.txtProtectTagPattern.Name = "txtProtectTagPattern";
            this.txtProtectTagPattern.Size = new System.Drawing.Size(306, 20);
            this.txtProtectTagPattern.TabIndex = 1;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(11, 20);
            this.label1.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(66, 13);
            this.label1.TabIndex = 0;
            this.label1.Text = "Tag  Pattern";
            // 
            // btnPerformOperation
            // 
            this.btnPerformOperation.Location = new System.Drawing.Point(204, 159);
            this.btnPerformOperation.Margin = new System.Windows.Forms.Padding(2);
            this.btnPerformOperation.Name = "btnPerformOperation";
            this.btnPerformOperation.Size = new System.Drawing.Size(147, 34);
            this.btnPerformOperation.TabIndex = 1;
            this.btnPerformOperation.Text = "PERFORM OPERATION";
            this.btnPerformOperation.UseVisualStyleBackColor = true;
            this.btnPerformOperation.Click += new System.EventHandler(this.btnPerformOperation_Click);
            // 
            // ProtectedMode
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(360, 201);
            this.Controls.Add(this.btnPerformOperation);
            this.Controls.Add(this.groupBox1);
            this.Margin = new System.Windows.Forms.Padding(2);
            this.Name = "ProtectedMode";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "Protected Mode";
            this.Load += new System.EventHandler(this.ProtectedMode_Load);
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.TextBox txtProtectPassword;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.ComboBox cboProtectMode;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.TextBox txtProtectTagPattern;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Button btnPerformOperation;
    }
}