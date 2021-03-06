<?php
/**
 * Created by PhpStorm.
 * User: Awalin Yudhana
 * Date: 21/04/2015
 * Time: 18:53
 */
defined('BASEPATH') OR exit('No direct script access allowed');

class Debit extends MX_Controller
{
    public function __construct()
    {
        parent::__construct();
        $this->acl->auth('debit');
        $this->id_staff = $this->session->userdata('uid');
    }

    public function index()
    {
        $data['success'] = $this->session->flashdata('success') != null ? $this->session->flashdata('success') : null;
        $this->db
            ->from('sales_order so')
            // ->join('proposal p', 'p.id_proposal = so.id_proposal','left')
            ->join('customer c', 'c.id_customer = so.id_customer');
        if ($this->input->post()) {

            $this->db->where('so.date >=', $this->input->post('date') . '-01')
                ->where('so.date <', "DATE_ADD( '" . $this->input->post('date') . "-01', INTERVAL 1 MONTH)", false);

        }
        $so = $this->db
            ->where('so.status_paid', false)
            ->where('so.active', true)
            ->order_by('so.id_sales_order  asc')
            ->get()
            ->result();
        $data['so'] = $so;

        $grand_total = $this->db->select_sum('grand_total')
            ->where(array('so.status_paid' => false))
            ->where('so.active', true)
            ->get('sales_order so')
            ->row();

        $paid = $this->db->select_sum('paid')
            ->where(array('so.status_paid' => false))
            ->where('so.active', true)
            ->get('sales_order so')
            ->row();

        $data['debit_total'] = $grand_total->grand_total - $paid->paid;

        $date_available = $this->db->select('MONTH(date) as month,YEAR(date) as year')
            ->where(array('so.status_paid' => false))
            ->group_by('month(date)')
            ->get('sales_order so')
            ->result();

        $array_month = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober',
            'Nopember', 'Desember'];

        $date = array('' => '');

        foreach ($date_available as $val) {
            $date[$val->year . '-' . str_pad($val->month, 2, "0", STR_PAD_LEFT)] = $array_month[$val->month - 1] . '-' . $val->year;
        }
        $data['date'] = $date;
        $this->parser->parse("debit.tpl", $data);
    }

    public function bill($id_sales_order)
    {

        $data['error'] = $this->session->flashdata('error') != null ? $this->session->flashdata('error') : null;
        if ($this->input->post()) {
            if ($this->form_validation->run('debit')) {
                $scan = '';
                if($this->input->post('payment_type') == "bg" && $this->input->post('date_withdrawal') == null){
                    $data['error'] = "Masukkan tanggal penarikan:";
                }else{
                    if (isset($_FILES['file']['size']) && ($_FILES['file']['size'] > 0)) {
                        $config['upload_path'] = './upload/debit';
                        $config['allowed_types'] = 'gif|jpg|png';
                        $config['max_size'] = '4048';
                        $config['max_width'] = '4024';
                        $config['max_height'] = '4668';
                        $config['encrypt_name'] = true;

                        $this->load->library('upload', $config);

                        if (!$this->upload->do_upload('file')) {
                            $this->session->set_flashdata('error',
                                $this->upload->display_errors(''));
                            redirect('debit/bill' . '/' . $id_sales_order);
                        }
                        $file = $this->upload->data();
                        $scan = base_url() . "upload/debit/" . $file['file_name'];

                        $data_insert = array(
                            'id_staff' => $this->id_staff,
                            'id_sales_order' => $id_sales_order,
                                'payment_type' => $this->input->post('payment_type'),
                                'amount' => $this->input->post('amount'),
                                'resi_number' => $this->input->post('resi_number'),
                                'date_withdrawal' => $this->input->post('date_withdrawal') == "" ?
                                    null : $this->input->post('date_withdrawal'),
                                'status' => $this->input->post('payment_type') == "bg" ? 0 : 1,
                            'file' => $scan
                        );

                        $this->db->insert('debit', $data_insert);

        //                $this->db
        //                    ->where('id_sales_order' , $id_sales_order)
        //                    ->set('status_extract',0)
        //                    ->update('sales_order');
                        $this->session->set_flashdata('success', 'Data berhasil disimpan');
                        redirect('debit');

                    }
                    else{
                        $data['error'] = "Masukkan bukti pembayaran";
                    }
                }
            }
        }
        $so = $this->db
            // ->select('so.*, c.*')
            ->from('sales_order so')
            // ->join('proposal p', 'p.id_proposal = so.id_proposal')
            ->join('customer c', 'c.id_customer = so.id_customer')
            ->where(array(
                'id_sales_order' => $id_sales_order
            ))
            ->get()
            ->row();

        $data['so'] = $so;
        $this->parser->parse("bill.tpl", $data);
    }


    public function update($id_debit)
    {
        $this->db
            ->where('id_debit',$id_debit)
            ->set('status',true)
            ->update('debit');
        $row = $this->db->get_where('debit',['id_debit'=>$id_debit])->row();
            redirect('debit/detail'.'/'.$row->id_sales_order);
    }

    public function detailBayar($id_sales_order)
    {
        $so = $this->db
            // ->select('so.*, c.*')
            ->from('sales_order so')
            // ->join('proposal p', 'p.id_proposal = so.id_proposal')
            ->join('customer c', 'c.id_customer = so.id_customer')
            ->where(array(
                'id_sales_order' => $id_sales_order
            ))
            ->get()
            ->row();

        $data['so'] = $so;

        $debit = $this->db->from('debit')
            ->join('staff', 'staff.id_staff = debit.id_staff')
            ->where('id_sales_order', $id_sales_order)
            ->get()
            ->result();
        $data['debit'] = $debit;
        $this->parser->parse("detail.tpl", $data);

    }
}