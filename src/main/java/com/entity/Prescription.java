package com.entity;

import java.sql.Date;
import java.sql.Timestamp;
import java.util.List;

public class Prescription {

    private int prescriptionId;
    private int appointmentId;
    private String diagnosis;
    private String adviceNotes;
    private Date followUpDate;
    private Timestamp createdAt;

    // This is important: A list to hold all the medicines
    private List<PrescriptionMedication> medications;

    public Prescription() {
        super();
    }

    // --- Add all Getters and Setters for all fields ---
    
    public int getPrescriptionId() {
        return prescriptionId;
    }

    public void setPrescriptionId(int prescriptionId) {
        this.prescriptionId = prescriptionId;
    }

    public int getAppointmentId() {
        return appointmentId;
    }

    public void setAppointmentId(int appointmentId) {
        this.appointmentId = appointmentId;
    }

    public String getDiagnosis() {
        return diagnosis;
    }

    public void setDiagnosis(String diagnosis) {
        this.diagnosis = diagnosis;
    }

    public String getAdviceNotes() {
        return adviceNotes;
    }

    public void setAdviceNotes(String adviceNotes) {
        this.adviceNotes = adviceNotes;
    }

    public Date getFollowUpDate() {
        return followUpDate;
    }

    public void setFollowUpDate(Date followUpDate) {
        this.followUpDate = followUpDate;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public List<PrescriptionMedication> getMedications() {
        return medications;
    }

    public void setMedications(List<PrescriptionMedication> medications) {
        this.medications = medications;
    }
}